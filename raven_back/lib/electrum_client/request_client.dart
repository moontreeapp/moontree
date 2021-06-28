/* 
https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
*/

import 'dart:async';
import 'dart:io';
import 'dart:convert' as convert;

import 'package:equatable/equatable.dart';
import 'package:pedantic/pedantic.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:json_rpc_2/src/utils.dart' as utils;
import 'package:stream_channel/stream_channel.dart';

import 'json_newline_transformer.dart';

bool acceptUnverified(X509Certificate certificate) {
  return true;
}

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

class ServerVersion {
  String name;
  String protocol;
  ServerVersion(this.name, this.protocol);
}

class Header {
  String hex;
  int height;
  Header(this.hex, this.height);
}

class ScriptHashBalance {
  int confirmed;
  int unconfirmed;
  ScriptHashBalance(this.confirmed, this.unconfirmed);

  int get value {
    return confirmed + unconfirmed;
  }

  @override
  String toString() {
    return 'ScriptHashBalance(confirmed: $confirmed, unconfirmed: $unconfirmed)';
  }
}

class ScriptHashHistory with EquatableMixin {
  int height;
  String txHash;
  ScriptHashHistory({required this.height, required this.txHash});

  @override
  List<Object> get props => [height, txHash];

  @override
  String toString() {
    return 'ScriptHashHistory(txHash: $txHash, height: $height)';
  }
}

class ScriptHashUnspent with EquatableMixin {
  int height;
  String txHash;
  int txPos;
  int value;

  ScriptHashUnspent(
      {required this.height,
      required this.txHash,
      required this.txPos,
      required this.value});

  factory ScriptHashUnspent.empty() {
    return ScriptHashUnspent(height: -1, txHash: '', txPos: -1, value: 0);
  }

  @override
  List<Object> get props => [txHash, txPos, value, height];

  @override
  String toString() {
    return 'ScriptHashUnspent(txHash: $txHash, txPos: $txPos, value: $value, height: $height)';
  }
}

class ElectrumSubscription extends Stream {
  final StreamController _controller = StreamController();
  final String method;
  final String paramsHash;
  // final JsonRpc2Client client;

  ElectrumSubscription(this.method, [this.paramsHash = '']);
  // ElectrumSubscription(this.eventName, this.id, this.client);

  String get requestId => '$method.$paramsHash';

  void close() {
    if (!_controller.isClosed) _controller.close();
  }

  @override
  StreamSubscription listen(void Function(dynamic)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // Future unsubscribe() {
  //   var c = Completer<Map>();
  //   var requestId = client._uuid.v4();
  //   client._requests[requestId] = c;
  //   client._peer.sendNotification(
  //       'unsubscribe', {'request_id': requestId, 'client_id': client.clientId, 'subscription_id': id});

  //   return c.future.then((_) {
  //     _close();
  //   });
  // }
}

class ElectrumClient {
  /// We use a Peer here (which implements both Server and Client sides of a
  /// Remote Procedure Call (RPC) interface) to communicate with an ElectrumX
  /// Ravencoin server. We need:
  ///
  /// - the Client side for the basic ability to call a 'procedure' (e.g.
  ///   'blockchain.scripthash.get_balance') on the remote server;
  ///
  /// - the Server side so that when we subscribe to an ongoing stream of
  ///   updates. The remote server can notify us of an update by calling our
  ///   registered 'procedures'.
  ///
  /// Note that notifications from the server use procedure names that match
  /// the initiating subscribe call--for example, we can start a subscription
  /// by calling 'blockchain.scripthash.subscribe', and the server will
  /// subsequently make calls to our 'blockchain.scripthash.subscribe' proc.
  rpc.Peer? _peer;

  final Map<String, List<ElectrumSubscription>> _subscriptions = {};

  Map<String, Function> get subscribables => {
        'blockchain.headers': _subscribeHeaders,
        'blockchain.scripthash': _subscribeScripthash,
        'blockchain.asset': _subscribeAsset,
      };

  ElectrumClient();

  Future connect({host, port = 50002, protocolVersion = '1.8'}) async {
    var socket = await SecureSocket.connect(host, port,
        timeout: connectionTimeout, onBadCertificate: acceptUnverified);
    var channel = StreamChannel(socket.cast<List<int>>(), socket);
    var channelUtf8 =
        channel.transform(StreamChannelTransformer.fromCodec(convert.utf8));
    var channelJson = jsonNewlineDocument
        .bind(channelUtf8)
        .transformStream(utils.ignoreFormatExceptions);
    _peer = rpc.Peer.withoutJson(channelJson);
    registerSubscribables();
    unawaited(_peer!.listen());
    if (protocolVersion != null) {
      await serverVersion(protocolVersion: protocolVersion);
    }
  }

  /// Registers each of the callbacks used when subscribing to a method
  void registerSubscribables() {
    rpc.Server server = _peer!;

    // This "fallback" handles all notifications from the ElectrumX server
    server.registerFallback((rpc.Parameters params) {
      var streams = _subscriptions[params.method] ?? [];
      // for (var stream in streams) {
      //   stream.
      // }
    });
  }

  Future<void> close() async {
    return _peer?.close();
  }

  Future request(String method, [parameters]) async {
    return await _peer?.sendRequest(method, parameters);
  }

  Future subscribe(String method, bool done, [parameters]) async {
    var proc = method + '.' + (done ? 'unsubscribe' : 'subscribe');
    return await request(proc, parameters);
  }

  Future<ServerVersion> serverVersion(
      {clientName = 'MTWallet', protocolVersion = '1.8'}) async {
    var proc = 'server.version';
    var response = await request(proc, [clientName, protocolVersion]);
    return ServerVersion(response[0], response[1]);
  }

  Future<Map<String, dynamic>> features() async {
    var proc = 'server.features';
    return await request(proc);
  }

  Future<ScriptHashBalance> getBalance({scriptHash}) async {
    var proc = 'blockchain.scripthash.get_balance';
    dynamic balance = await request(proc, [scriptHash]);
    return ScriptHashBalance(balance['confirmed'], balance['unconfirmed']);
  }

  Future<List<ScriptHashHistory>> getHistory({scriptHash}) async {
    var proc = 'blockchain.scripthash.get_history';
    List<dynamic> history = await request(proc, [scriptHash]);
    return (history.map((response) => ScriptHashHistory(
        height: response['height'], txHash: response['tx_hash']))).toList();
  }

  Future<List<ScriptHashUnspent>> getUTXOs({scriptHash}) async {
    var proc = 'blockchain.scripthash.listunspent';
    List<dynamic> unspent = await request(proc, [scriptHash]);
    return (unspent.map((res) => ScriptHashUnspent(
        height: res['height'],
        txHash: res['tx_hash'],
        txPos: res['tx_pos'],
        value: res['value']))).toList();
  }

  // Subscribe 'blockchain.headers'

  void addSubscription(ElectrumSubscription subscription) {
    if (!_subscriptions.containsKey(subscription.requestId)) {
      _subscriptions[subscription.requestId] = [];
    }
    _subscriptions[subscription.requestId]!.add(subscription);
  }

  Future<ElectrumSubscription> subscribeHeaders({done = false}) async {
    // var completer = Completer<>()
    var subscription = ElectrumSubscription('blockchain.headers.subscribe');
    addSubscription(subscription);
    Map<String, dynamic> header = await subscribe('blockchain.headers', done);
    var first = Header(header['hex'], header['height']);

    return subscription;
  }

  void _subscribeHeaders(rpc.Parameters params) {
    print('${params.method}: ${params.value}');
  }

  // Subscribe scripthash status

  Future<String?> subscribeScripthash({scriptHash, done = false}) async {
    return await subscribe('blockchain.scripthash', done, [scriptHash]);
  }

  void _subscribeScripthash(rpc.Parameters params) {
    print('${params.method}: ${params.value}');
  }

  // Subscribe ravencoin asset

  Future<String?> subscribeAsset({assetName, done = false}) async {
    return await subscribe('blockchain.asset', done, [assetName]);
  }

  void _subscribeAsset(rpc.Parameters params) {
    print('${params.method}: ${params.value}');
  }
}
