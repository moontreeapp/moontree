import 'dart:async';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// we use the electrum server directly for determining our UTXO set
///
/// must re-run this when we switch wallets
/// must re-run this after we get all updates on addresses
class UnspentService {
  Map<Security, Set<ScripthashUnspent>> unspentsBySecurity = {};

  Security defaultSecurity(Security? security) =>
      security ?? res.securities.RVN;

  Iterable<String> defaultScripthashes(Iterable<String>? scripthashes) =>
      scripthashes ??
      res.wallets.currentWallet.addresses.map((e) => e.scripthash).toList();

  Future<void> pull({
    Iterable<String>? scripthashes,
    Security? security,
  }) async {
    security = defaultSecurity(security);
    scripthashes = defaultScripthashes(scripthashes);
    print('Downloading Unspents');
    var s = Stopwatch()..start();
    for (var scripthash in scripthashes) {
      if (security == res.securities.RVN) {
        var utxos = await services.client.client!.getUnspent(scripthash);
        //var utxos = await services.client.client!.AssetGetUnspent(scripthash);
        if (!unspentsBySecurity.keys.contains(security)) {
          unspentsBySecurity[security] = <ScripthashUnspent>{};
        }
        unspentsBySecurity[security]!.addAll(utxos);
        for (var u in utxos) {
          print(u);
        }
      }
    }
    print(
        'Unspents downloaded: ${scripthashes.length} ${s.elapsed} ${total()}');
  }

  int total([Security? security]) =>
      unspentsBySecurity.keys.contains(defaultSecurity(security))
          ? unspentsBySecurity[defaultSecurity(security)]!.fold(
              0, (int total, ScripthashUnspent item) => item.value + total)
          : 0;

  void assertSufficientFunds(int amount, Security? security) {
    if (total(defaultSecurity(security)) >= amount) {
      throw InsufficientFunds();
    }
  }

  Set<ScripthashUnspent> getUnspents(Security? security) =>
      unspentsBySecurity[defaultSecurity(security)] ?? <ScripthashUnspent>{};
}
