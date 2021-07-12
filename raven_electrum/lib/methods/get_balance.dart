import '../raven_electrum_client.dart';

class ScripthashBalance {
  int confirmed;
  int unconfirmed;
  ScripthashBalance(this.confirmed, this.unconfirmed);

  int get value {
    return confirmed + unconfirmed;
  }

  @override
  String toString() {
    return 'ScripthashBalance(confirmed: $confirmed, unconfirmed: $unconfirmed)';
  }
}

extension GetBalanceMethod on RavenElectrumClient {
  Future<ScripthashBalance> getBalance(scripthash) async {
    var proc = 'blockchain.scripthash.get_balance';
    dynamic balance = await request(proc, [scripthash]);
    return ScripthashBalance(balance['confirmed'], balance['unconfirmed']);
  }

  /// returns balances in the same order as scripthashes passed in
  Future<List<T>> getBalances<T>({required List<String> scripthashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getBalance(scripthash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
