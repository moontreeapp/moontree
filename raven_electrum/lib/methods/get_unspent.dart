import 'package:equatable/equatable.dart';

import '../../raven_electrum_client.dart';

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

extension GetUnspentMethod on RavenElectrumClient {
  Future<List<ScriptHashUnspent>> getUnspent({scriptHash}) async {
    var proc = 'blockchain.scripthash.listunspent';
    List<dynamic> unspent = await request(proc, [scriptHash]);
    return (unspent.map((res) => ScriptHashUnspent(
        height: res['height'],
        txHash: res['tx_hash'],
        txPos: res['tx_pos'],
        value: res['value']))).toList();
  }

  /// returns unspents in the same order as scripthashes passed in
  Future<List<T>> getUnspents<T>({required List<String> scriptHashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scriptHash in scriptHashes) {
        futures.add(getUnspent(scriptHash: scriptHash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
