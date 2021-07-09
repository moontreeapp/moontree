import 'package:equatable/equatable.dart';

import '../../raven_electrum_client.dart';

class ScripthashUnspent with EquatableMixin {
  int height;
  String txHash;
  int txPos;
  int value;

  ScripthashUnspent(
      {required this.height,
      required this.txHash,
      required this.txPos,
      required this.value});

  factory ScripthashUnspent.empty() {
    return ScripthashUnspent(height: -1, txHash: '', txPos: -1, value: 0);
  }

  @override
  List<Object> get props => [txHash, txPos, value, height];

  @override
  String toString() {
    return 'ScripthashUnspent(txHash: $txHash, txPos: $txPos, value: $value, height: $height)';
  }
}

extension GetUnspentMethod on RavenElectrumClient {
  Future<List<ScripthashUnspent>> getUnspent({scripthash}) async {
    var proc = 'blockchain.scripthash.listunspent';
    List<dynamic> unspent = await request(proc, [scripthash]);
    return (unspent.map((res) => ScripthashUnspent(
        height: res['height'],
        txHash: res['tx_hash'],
        txPos: res['tx_pos'],
        value: res['value']))).toList();
  }

  /// returns unspents in the same order as scripthashes passed in
  Future<List<T>> getUnspents<T>({required List<String> scripthashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getUnspent(scripthash: scripthash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
