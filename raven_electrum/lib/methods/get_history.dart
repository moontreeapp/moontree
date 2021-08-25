import 'package:equatable/equatable.dart';

import '../raven_electrum_client.dart';

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
  Future<List<ScripthashHistory>> getHistory(scripthash) async =>
      ((await request(
        'blockchain.scripthash.get_history',
        [scripthash],
      ) as List<dynamic>)
          .map((response) => ScripthashHistory(
              height: response['height'],
              txHash: response['tx_hash']))).toList();

  /// returns histories in the same order as scripthashes passed in
  Future<List<List<ScripthashHistory>>> getHistories(
    List<String> scripthashes,
  ) async {
    var futures = <Future<List<ScripthashHistory>>>[];
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getHistory(scripthash));
      }
    });
    List<List<ScripthashHistory>> results =
        await Future.wait<List<ScripthashHistory>>(futures);
    return results;
  }
}
