import 'package:equatable/equatable.dart';

import '../../raven_electrum_client.dart';

class ScripthashHistory with EquatableMixin {
  int height;
  String txHash;
  ScripthashHistory({required this.height, required this.txHash});

  @override
  List<Object> get props => [height, txHash];

  @override
  String toString() {
    return 'ScripthashHistory(txHash: $txHash, height: $height)';
  }
}

extension GetHistoryMethod on RavenElectrumClient {
  Future<List<ScripthashHistory>> getHistory({scripthash}) async {
    var proc = 'blockchain.scripthash.get_history';
    List<dynamic> history = await request(proc, [scripthash]);
    return (history.map((response) => ScripthashHistory(
        height: response['height'], txHash: response['tx_hash']))).toList();
  }

  /// returns histories in the same order as scripthashes passed in
  Future<List<T>> getHistories<T>({required List<String> scripthashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getHistory(scripthash: scripthash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
