/* 
https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
*/

import 'dart:io';
import 'dart:convert' as convert;

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

  Future<String> request(String method, [parameters]) async {
    var response = await _client?.sendRequest(method, [parameters]);
    return response.toString();
  }

  Future<ServerVersion> serverVersion(
      {clientName = 'MTWallet', protocolVersion = '1.8'}) async {
    var response = await _client
        ?.sendRequest('server.version', [clientName, protocolVersion]);
    return ServerVersion(response[0], response[1]);
  }

  Future<Map<String, dynamic>> features() async {
    var response = await _client?.sendRequest('server.features');
    return response;
  }

  Future<Map<String, int>> getBalance({scriptHash}) async {
    Map<String, dynamic> response = await _client
        ?.sendRequest('blockchain.scripthash.get_balance', [scriptHash]);
    return response.map((key, value) => MapEntry(key, value));
  }

  Future<List<dynamic>> getHistory({scriptHash}) async {
    List<dynamic> response = await _client
        ?.sendRequest('blockchain.scripthash.get_history', [scriptHash]);
    return response; //List<Map<String, dynamic>> List(...map((key, value) => MapEntry(key, value)));
  }

  //Future<List<Map<String, dynamic>>> getUTXOs({scriptHash}) async {  // fix with Duane
  Future<List<dynamic>> getUTXOs({scriptHash}) async {
    /* return example: [{ "tx_pos": 0, "value": 45318048, "tx_hash": "9...f", "height": 437146},] */
    var response = await _client
        ?.sendRequest('blockchain.scripthash.listunspent', [scriptHash]);
    return response;
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
