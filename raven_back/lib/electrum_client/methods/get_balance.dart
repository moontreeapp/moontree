import '../../electrum_client.dart';

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

extension GetBalanceMethod on ElectrumClient {
  Future<ScriptHashBalance> getBalance({scriptHash}) async {
    var proc = 'blockchain.scripthash.get_balance';
    dynamic balance = await request(proc, [scriptHash]);
    return ScriptHashBalance(balance['confirmed'], balance['unconfirmed']);
  }

  /// returns balances in the same order as scripthashes passed in
  Future<List<T>> getBalances<T>({required List<String> scriptHashes}) async {
    var futures = <Future>[];
    var results;
    peer.withBatch(() {
      for (var scriptHash in scriptHashes) {
        futures.add(getBalance(scriptHash: scriptHash));
      }
    });
    results = await Future.wait(futures);
    return results;
  }
}
