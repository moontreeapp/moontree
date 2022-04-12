import 'package:equatable/equatable.dart';

import '../../raven_electrum.dart';

class ScripthashUnspent with EquatableMixin {
  String scripthash;
  int height;
  String txHash;
  int txPos;
  int value;
  String? symbol; // symbol of asset null is rvn itself.
  late String? memo; // memo grabbed after the fact

  ScripthashUnspent(
      {required this.scripthash,
      required this.height,
      required this.txHash,
      required this.txPos,
      required this.value,
      this.symbol,
      this.memo});

  factory ScripthashUnspent.empty() {
    return ScripthashUnspent(
        scripthash: '', height: -1, txHash: '', txPos: -1, value: 0);
  }

  @override
  List<Object> get props =>
      [scripthash, txHash, txPos, value, height, symbol ?? '', memo ?? ''];

  @override
  String toString() {
    return 'ScripthashUnspent(scripthash: $scripthash, txHash: $txHash, txPos: $txPos, value: $value, height: $height, symbol: $symbol, memo: $memo)';
  }
}

extension GetUnspentMethod on RavenElectrumClient {
  Future<List<ScripthashUnspent>> getUnspent(scripthash) async =>
      ((await request(
        'blockchain.scripthash.listunspent',
        [scripthash],
      ) as List<dynamic>)
          .map((res) => ScripthashUnspent(
              scripthash: scripthash,
              height: res['height'],
              txHash: res['tx_hash'],
              txPos: res['tx_pos'],
              value: res['value']))).toList();

  /// returns unspents in the same order as scripthashes passed in
  Future<List<List<ScripthashUnspent>>> getUnspents(
    Iterable<String> scripthashes,
  ) async {
    var futures = <Future<List<ScripthashUnspent>>>[];
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getUnspent(scripthash));
      }
    });
    List<List<ScripthashUnspent>> results =
        await Future.wait<List<ScripthashUnspent>>(futures);
    return results;
  }

  Future<List<ScripthashUnspent>> getAssetUnspent(scripthash) async =>
      ((await request(
        'blockchain.scripthash.listassets',
        [scripthash],
      ) as List<dynamic>)
          .map((res) => ScripthashUnspent(
              scripthash: scripthash,
              height: res['height'],
              txHash: res['tx_hash'],
              txPos: res['tx_pos'],
              value: res['value'],
              symbol: res['name']))).toList();

  /// returns unspents in the same order as scripthashes passed in
  Future<List<List<ScripthashUnspent>>> getAssetUnspents(
    Iterable<String> scripthashes,
  ) async {
    var futures = <Future<List<ScripthashUnspent>>>[];
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getAssetUnspent(scripthash));
      }
    });
    List<List<ScripthashUnspent>> results =
        await Future.wait<List<ScripthashUnspent>>(futures);
    return results;
  }
}
