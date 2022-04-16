import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import 'package:synchronized/synchronized.dart';

/// we use the electrum server directly for determining our UTXO set
class UnspentService {
  // "Security name" -> address -> {unspents}
  // This can be concurrently modified while we iterate over keys, i.e. recalc balances
  final Map<String, Map<String, Set<ScripthashUnspent>>> _unspentsBySymbol = {};
  // Ideally we'd have some kind of RWLock
  final unspentLock = Lock();

  String defaultSymbol(String? symbol) => symbol ?? 'RVN';

  Iterable<String> defaultScripthashes(Iterable<String>? scripthashes) =>
      scripthashes ??
      res.wallets.currentWallet.addresses.map((e) => e.scripthash).toList();

  void _clearUnspentsForScripthash(String scripthash, String symbol) {
    _unspentsBySymbol[symbol]?[scripthash]?.clear();
  }

  void _addUnspent({
    required String symbol,
    required Iterable<ScripthashUnspent> unspents,
    bool subscribe = false,
  }) {
    if (unspents.isNotEmpty) {
      if (_unspentsBySymbol.keys.isEmpty) {
        streams.app.triggers.add(ThresholdTrigger.backup);
      }
      if (!_unspentsBySymbol.keys.contains(symbol)) {
        _unspentsBySymbol[symbol] = <String, Set<ScripthashUnspent>>{};
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
        if (!_unspentsBySymbol[symbol]!.containsKey(unspent.scripthash)) {
          _unspentsBySymbol[symbol]![unspent.scripthash] =
              <ScripthashUnspent>{};
        }
        _unspentsBySymbol[symbol]![unspent.scripthash]!.add(unspent);
      }
    }
  }

  Future<void> pull({Iterable<String>? scripthashes, bool? updateRVN}) async {
    await unspentLock.synchronized(() async {
      final new_scripthashes = defaultScripthashes(scripthashes);
      final rvn = 'RVN';
      if (updateRVN ?? true) {
        var utxos =
            (await services.client.client!.getUnspents(new_scripthashes))
                .expand((i) => i);
        // Wipe relevant unspents and re-add
        new_scripthashes.forEach((x) => _clearUnspentsForScripthash(x, rvn));
        _addUnspent(symbol: rvn, unspents: utxos);
      }
      if (!(updateRVN ?? false)) {
        var utxos =
            (await services.client.client!.getAssetUnspents(new_scripthashes))
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
              downloaded[utxo.symbol!]![utxo.scripthash] =
                  <ScripthashUnspent>{};
            }
            downloaded[utxo.symbol!]![utxo.scripthash]!.add(utxo);
          }
        }

        // And then remove and add
        for (final symbol in downloaded.keys) {
          final scripthashes_internal = downloaded[symbol]!.keys;
          scripthashes_internal
              .forEach((x) => _clearUnspentsForScripthash(x, symbol));
          for (final scripthash_internal in scripthashes_internal) {
            _addUnspent(
                symbol: symbol,
                unspents: downloaded[symbol]![scripthash_internal]!,
                subscribe: true);
          }
        }
      }
    });
  }

  // TODO: Maybe cache instead of calculating each time?
  Future<int> total([String? symbol]) async =>
      await unspentLock.synchronized(() {
        final result = _unspentsBySymbol.keys.contains(defaultSymbol(symbol))
            ? _unspentsBySymbol[defaultSymbol(symbol)]!
                .values // List of iterable of items
                .expand((element) => element) // Flatten the list of iterables
                .fold(0,
                    (int total, ScripthashUnspent item) => item.value + total)
            : 0;
        return result;
      });

  Future<void> assertSufficientFunds(int amount, String? symbol) async {
    if (await total(defaultSymbol(symbol)) < amount) {
      throw InsufficientFunds();
    }
  }

  Future<Set<ScripthashUnspent>> getUnspents(String? symbol) async =>
      await unspentLock.synchronized(() =>
          _unspentsBySymbol[defaultSymbol(symbol)]
              ?.values
              .expand((element) => element)
              .toSet() ??
          <ScripthashUnspent>{});

  Future<Iterable<String>> getSymbols() async =>
      await unspentLock.synchronized(() => _unspentsBySymbol.keys.toSet());
}
