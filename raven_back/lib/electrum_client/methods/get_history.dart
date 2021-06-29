import 'package:equatable/equatable.dart';

import '../../electrum_client.dart';

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

extension GetHistoryMethod on ElectrumClient {
  Future<List<ScriptHashHistory>> getHistory({scriptHash}) async {
    var proc = 'blockchain.scripthash.get_history';
    List<dynamic> history = await request(proc, [scriptHash]);
    return (history.map((response) => ScriptHashHistory(
        height: response['height'], txHash: response['tx_hash']))).toList();
  }

  /// returns histories in the same order as scripthashes passed in
  Future<List<T>> getHistories<T>({required List<String> scriptHashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scriptHash in scriptHashes) {
        futures.add(getHistory(scriptHash: scriptHash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
