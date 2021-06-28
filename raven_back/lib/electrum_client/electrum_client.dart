/* 
https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
*/

import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:raven/electrum_client/subscribing_client.dart';

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

class ElectrumClient extends SubscribingClient {
  ElectrumClient(channel) : super(channel) {
    registerSubscribable(Subscribable('blockchain.headers'));
    registerSubscribable(
        Subscribable('blockchain.scripthash', (params) => params.asList.first));
    registerSubscribable(
        Subscribable('blockchain.asset', (params) => params.asList.first));
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

  // Stream<ElectrumSubscription> subscribeHeaders({done = false}) async {
  //   // var completer = Completer<>()
  //   var subscription = ElectrumSubscription('blockchain.headers.subscribe');
  //   addSubscription(subscription);
  //   Map<String, dynamic> header = await subscribe('blockchain.headers', done);
  //   var first = Header(header['hex'], header['height']);

  //   return subscription;
  // }
}
