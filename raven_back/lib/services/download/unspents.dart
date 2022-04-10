import 'dart:async';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// we use the electrum server directly for determining our UTXO set
///
/// must re-run this when we switch wallets
/// must re-run this after we get all updates on addresses
class UnspentService {
  Map<String, Set<ScripthashUnspent>> unspentsBySymbol = {};

  String defaultSymbol(String? symbol) => symbol ?? 'RVN';

  Iterable<String> defaultScripthashes(Iterable<String>? scripthashes) =>
      scripthashes ??
      res.wallets.currentWallet.addresses.map((e) => e.scripthash).toList();

  Future<void> pull({Iterable<String>? scripthashes, bool? updateRVN}) async {
    scripthashes = defaultScripthashes(scripthashes);
    var rvn = 'RVN';
    if (updateRVN ?? true) {
      var utxos = (await services.client.client!.getUnspents(scripthashes))
          .expand((i) => i);
      if (!unspentsBySymbol.keys.contains(rvn)) {
        unspentsBySymbol[rvn] = <ScripthashUnspent>{};
      }
      unspentsBySymbol[rvn]!.addAll(utxos);
    }
    if (!(updateRVN ?? false)) {
      var utxos = (await services.client.client!.getAssetUnspents(scripthashes))
          .expand((i) => i);
      for (var utxo in utxos) {
        if (!unspentsBySymbol.keys.contains(utxo.symbol)) {
          unspentsBySymbol[utxo.symbol!] = <ScripthashUnspent>{};
        }
        unspentsBySymbol[utxo.symbol]!.addAll(utxos);
      }
    }
  }

  int total([String? symbol]) =>
      unspentsBySymbol.keys.contains(defaultSymbol(symbol))
          ? unspentsBySymbol[defaultSymbol(symbol)]!.fold(
              0, (int total, ScripthashUnspent item) => item.value + total)
          : 0;

  void assertSufficientFunds(int amount, String? symbol) {
    if (total(defaultSymbol(symbol)) >= amount) {
      throw InsufficientFunds();
    }
  }

  Set<ScripthashUnspent> getUnspents(String? symbol) =>
      unspentsBySymbol[defaultSymbol(symbol)] ?? <ScripthashUnspent>{};
}
