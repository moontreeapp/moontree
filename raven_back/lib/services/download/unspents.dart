import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// we use the electrum server directly for determining our UTXO set
class UnspentService {
  Map<String, Set<ScripthashUnspent>> unspentsBySymbol = {};

  String defaultSymbol(String? symbol) => symbol ?? 'RVN';

  Iterable<String> defaultScripthashes(Iterable<String>? scripthashes) =>
      scripthashes ??
      res.wallets.currentWallet.addresses.map((e) => e.scripthash).toList();

  void addUnspent({
    required String symbol,
    required Iterable<ScripthashUnspent> unspents,
    bool subscribe = false,
  }) {
    if (unspents.isNotEmpty) {
      if (unspentsBySymbol.keys.isEmpty) {
        streams.app.triggers.add(ThresholdTrigger.backup);
      }
      if (!unspentsBySymbol.keys.contains(symbol)) {
        unspentsBySymbol[symbol] = <ScripthashUnspent>{};
        if (subscribe) {
          // Subscribe to a dummy asset of this type
          // This method checks if we're already subscribed and
          // handles downloads if we are not
          services.client.subscribe.toAsset(Asset(
              symbol: symbol,
              satsInCirculation: 0,
              divisibility: 0,
              reissuable: false,
              metadata: '',
              transactionId: '',
              position: 0));
        }
      }
      unspentsBySymbol[symbol]!.addAll(unspents);
    }
  }

  Future<void> pull({Iterable<String>? scripthashes, bool? updateRVN}) async {
    scripthashes = defaultScripthashes(scripthashes);
    var rvn = 'RVN';
    if (updateRVN ?? true) {
      var utxos = (await services.client.client!.getUnspents(scripthashes))
          .expand((i) => i);
      addUnspent(symbol: rvn, unspents: utxos);
    }
    if (!(updateRVN ?? false)) {
      var utxos = (await services.client.client!.getAssetUnspents(scripthashes))
          .expand((i) => i);
      for (var utxo in utxos) {
        if (utxo.symbol != null) {
          addUnspent(symbol: utxo.symbol!, unspents: {utxo}, subscribe: true);
        }
      }
    }
  }

  int total([String? symbol]) =>
      unspentsBySymbol.keys.contains(defaultSymbol(symbol))
          ? unspentsBySymbol[defaultSymbol(symbol)]!.fold(
              0, (int total, ScripthashUnspent item) => item.value + total)
          : 0;

  void assertSufficientFunds(int amount, String? symbol) {
    if (total(defaultSymbol(symbol)) < amount) {
      throw InsufficientFunds();
    }
  }

  Set<ScripthashUnspent> getUnspents(String? symbol) =>
      unspentsBySymbol[defaultSymbol(symbol)] ?? <ScripthashUnspent>{};
}
