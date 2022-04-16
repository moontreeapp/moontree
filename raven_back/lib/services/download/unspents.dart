import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// we use the electrum server directly for determining our UTXO set
class UnspentService {
  // "Security name" -> address -> {unspents}
  Map<String, Map<String, Set<ScripthashUnspent>>> unspentsBySymbol = {};

  String defaultSymbol(String? symbol) => symbol ?? 'RVN';

  Iterable<String> defaultScripthashes(Iterable<String>? scripthashes) =>
      scripthashes ??
      res.wallets.currentWallet.addresses.map((e) => e.scripthash).toList();

  void clearUnspentsForScripthash(String scripthash, String symbol) {
    unspentsBySymbol[symbol]?[scripthash]?.clear();
  }

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
        unspentsBySymbol[symbol] = <String, Set<ScripthashUnspent>>{};
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
      for (var unspent in unspents) {
        if (!unspentsBySymbol[symbol]!.containsKey(unspent.scripthash)) {
          unspentsBySymbol[symbol]![unspent.scripthash] = <ScripthashUnspent>{};
        }
        unspentsBySymbol[symbol]![unspent.scripthash]!.add(unspent);
      }
    }
  }

  Future<void> pull({Iterable<String>? scripthashes, bool? updateRVN}) async {
    scripthashes = defaultScripthashes(scripthashes);

    var rvn = 'RVN';
    if (updateRVN ?? true) {
      var utxos = (await services.client.client!.getUnspents(scripthashes))
          .expand((i) => i);
      // Wipe relevant unspents and re-add
      scripthashes.forEach((x) => clearUnspentsForScripthash(x, rvn));
      addUnspent(symbol: rvn, unspents: utxos);
    }
    if (!(updateRVN ?? false)) {
      var utxos = (await services.client.client!.getAssetUnspents(scripthashes))
          .expand((i) => i);

      // Parse it into something more digestable
      final downloaded = <String, Map<String, Set<ScripthashUnspent>>>{};
      for (final utxo in utxos) {
        if (utxo.symbol != null) {
          // Should never be null but can't hurt to be safe
          if (!downloaded.containsKey(utxo.symbol!)) {
            downloaded[utxo.symbol!] = <String, Set<ScripthashUnspent>>{};
          }
          if (!downloaded[utxo.symbol!]!.containsKey(utxo.scripthash)) {
            downloaded[utxo.symbol!]![utxo.scripthash] = <ScripthashUnspent>{};
          }
          downloaded[utxo.symbol!]![utxo.scripthash]!.add(utxo);
        }
      }

      // And then remove and add
      for (final symbol in downloaded.keys) {
        final scripthashes_internal = downloaded[symbol]!.keys;
        scripthashes_internal
            .forEach((x) => clearUnspentsForScripthash(x, symbol));
        for (final scripthash_internal in scripthashes_internal) {
          addUnspent(
              symbol: symbol,
              unspents: downloaded[symbol]![scripthash_internal]!,
              subscribe: true);
        }
      }
    }
  }

  // TODO: Maybe cache instead of calculating each time?
  int total([String? symbol]) => unspentsBySymbol.keys
          .contains(defaultSymbol(symbol))
      ? unspentsBySymbol[defaultSymbol(symbol)]!
          .values // List of iterable of items
          .expand((element) => element) // Flatten the list of iterables
          .fold(0, (int total, ScripthashUnspent item) => item.value + total)
      : 0;

  void assertSufficientFunds(int amount, String? symbol) {
    if (total(defaultSymbol(symbol)) < amount) {
      throw InsufficientFunds();
    }
  }

  Set<ScripthashUnspent> getUnspents(String? symbol) =>
      unspentsBySymbol[defaultSymbol(symbol)]
          ?.values
          .expand((element) => element)
          .toSet() ??
      <ScripthashUnspent>{};
}
