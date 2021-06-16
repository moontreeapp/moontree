import 'dart:convert';

import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:stream_channel/stream_channel.dart';

class RavenClient {
  rpc.Client _client;

  RavenClient(StreamChannel<String> channel) : _client = rpc.Client(channel) {}

  void listen() {
    _client.listen();
  }

  Future<String> serverVersion() async {
    var response = await _client
        // .sendRequest('server.version', [clientName, protocolVersion]);
        .sendRequest('server.version');
    return response.toString();
  }

  Future<String> relayFee() async {
    var response = await _client.sendRequest('blockchain.relayfee');
    return response.toString();
  }

  Future<String> getBalance() async {
    var response =
        await _client.sendRequest('blockchain.scripthash.get_balance');
    return response.toString();
  }
}
