import 'package:equatable/equatable.dart';

import '../raven_electrum_client.dart';

class ScripthashUnspent with EquatableMixin {
  String scripthash;
  int height;
  String txHash;
  int txPos;
  int value;
  String? ticker; // ticker of asset null is rvn itself.

  ScripthashUnspent(
      {required this.scripthash,
      required this.height,
      required this.txHash,
      required this.txPos,
      required this.value,
      this.ticker});

  factory ScripthashUnspent.empty() {
    return ScripthashUnspent(
        scripthash: '', height: -1, txHash: '', txPos: -1, value: 0);
  }

  @override
  List<Object> get props =>
      [scripthash, txHash, txPos, value, height, ticker ?? ''];

  @override
  String toString() {
    return 'ScripthashUnspent(scripthash: $scripthash, txHash: $txHash, txPos: $txPos, value: $value, height: $height, ticker: $ticker)';
  }
}

extension GetUnspentMethod on RavenElectrumClient {
  Future<List<ScripthashUnspent>> getUnspent(scripthash) async {
    var proc = 'blockchain.scripthash.listunspent';
    List<dynamic> unspent = await request(proc, [scripthash]);
    return (unspent.map((res) => ScripthashUnspent(
        scripthash: scripthash,
        height: res['height'],
        txHash: res['tx_hash'],
        txPos: res['tx_pos'],
        value: res['value']))).toList();
  }

  /// returns unspents in the same order as scripthashes passed in
  Future<List<T>> getUnspents<T>(List<String> scripthashes) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getUnspent(scripthash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }

  Future<List<ScripthashUnspent>> getAssetUnspent(scripthash) async {
    var proc = 'blockchain.scripthash.listassets';
    List<dynamic> unspent = await request(proc, [scripthash]);
    return (unspent.map((res) => ScripthashUnspent(
        scripthash: scripthash,
        height: res['height'],
        txHash: res['tx_hash'],
        txPos: res['tx_pos'],
        value: res['value'],
        ticker: res['name']))).toList();
  }

  /// returns unspents in the same order as scripthashes passed in
  Future<List<T>> getAssetUnspents<T>(List<String> scripthashes) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getAssetUnspent(scripthash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
