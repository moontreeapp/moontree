import 'dart:async';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// we use the electrum server directly for determining our UTXO set
///
/// must re-run this when we switch wallets
/// must re-run this after we get all updates on addresses
class UnspentService {
  Map<Security, List<ScripthashUnspent>> unspentsBySecurity = {};

  Future<void> pullUnspents(
    List<String> scripthashes, {
    Security? security,
  }) async {
    security = defaultSecurity(security);
    print('Downloading Unspents');
    var s = Stopwatch()..start();
    for (var scripthash in scripthashes) {
      if (security == res.securities.RVN) {
        var utxos = await services.client.client!.getUnspent(scripthash);
        //var utxos = await services.client.client!.AssetGetUnspent(scripthash);
        if (!unspentsBySecurity.keys.contains(security)) {
          unspentsBySecurity[security] = <ScripthashUnspent>[];
        }
        unspentsBySecurity[security]!.addAll(utxos);
        for (var u in utxos) {
          print(u);
        }
      }
    }
    print('Unspents downloaded: ${s.elapsed} $unspentsBySecurity');
  }

  int total(Security? security) =>
      unspentsBySecurity[defaultSecurity(security)]!.fold(
          0,
          (int previousValue, ScripthashUnspent element) =>
              element.value + previousValue);

  void assertSufficientFunds(int amount, Security? security) {
    if (total(defaultSecurity(security)) >= amount) {
      throw InsufficientFunds();
    }
  }

  Security defaultSecurity(Security? security) =>
      security ?? res.securities.RVN;

  List<ScripthashUnspent> getUnspents(Security? security) =>
      unspentsBySecurity[defaultSecurity(security)] ?? <ScripthashUnspent>[];
}
