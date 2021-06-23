/* 
https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
*/

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

class ScriptHashUnspent extends ScriptHashHistory {
  int txPos;
  int value;
  ScriptHashUnspent(
      {required height,
      required txHash,
      required this.txPos,
      required this.value})
      : super(height: height, txHash: txHash);

  @override
  List<Object> get props => [txHash, txPos, value, height];

  @override
  String toString() {
    return 'ScriptHashUnspent(txHash: $txHash, txPos: $txPos, value: $value, height: $height)';
  }
}

class ElectrumClient {
  rpc.Client? _client;

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
    _client = rpc.Client.withoutJson(channelJson);
    unawaited(_client!.listen());
    if (protocolVersion != null) {
      await serverVersion(protocolVersion: protocolVersion);
    }
  }

  Future<dynamic>? close() {
    return _client?.close();
  }

  Future request(String method, [parameters]) async {
    return await _client?.sendRequest(method, parameters);
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

  Future<dynamic> subscribeTo({scriptHash}) async {
    /* I'm not sure I understand how subscriptions work -
    do they require a wss connection to be effective?
    they're pushing data to us, are they not? */
    var response = await _client
        ?.sendRequest('blockchain.scripthash.subscribe', [scriptHash]);
    return response;
  }
}
