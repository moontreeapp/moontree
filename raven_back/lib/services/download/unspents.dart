import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import 'package:tuple/tuple.dart';

/// we use the electrum server directly for determining our UTXO set
class UnspentService {
  // "Security name" -> address -> {unspents}
  // This can be concurrently modified while we iterate over keys, i.e. recalc balances
  final Map<String, Map<String, Set<ScripthashUnspent>>> _unspentsBySymbol = {};
  final _unspentsLock = ReaderWriterLock();

  final Map<String, List<int>> _cachedBySymbol = {};
  final _cachedBySymbolLock = ReaderWriterLock();

  String defaultSymbol(String? symbol) => symbol ?? res.securities.RVN.symbol;

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
    final new_scripthashes = defaultScripthashes(scripthashes);
    final rvn = res.securities.RVN.symbol;
    if (updateRVN ?? true) {
      var utxos = (await services.client.client!.getUnspents(new_scripthashes))
          .expand((i) => i);

      // Wipe relevant unspents and re-add
      await _unspentsLock.enterRead();
      // If we have new utxos, get the vouts now.
      final new_utxos = utxos.toSet().difference(
          (_unspentsBySymbol[rvn] ?? <String, Set<ScripthashUnspent>>{})
              .values
              .expand((element) => element)
              .toSet());
      await _unspentsLock.exitRead();
      new_utxos.removeWhere((element) =>
          res.vouts.byTransactionPosition
              .getOne(element.txHash, element.txPos) !=
          null);
      await services.download.history
          .getTransactions(new_utxos.map((x) => x.txHash));

      // New info; clear cache
      await _cachedBySymbolLock.enterWrite();
      _cachedBySymbol.remove(rvn);
      await _cachedBySymbolLock.exitWrite();

      await _unspentsLock.enterWrite();
      new_scripthashes.forEach((x) => _clearUnspentsForScripthash(x, rvn));
      _addUnspent(symbol: rvn, unspents: utxos);
      await _unspentsLock.exitWrite();
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
            downloaded[utxo.symbol!]![utxo.scripthash] = <ScripthashUnspent>{};
          }
          downloaded[utxo.symbol!]![utxo.scripthash]!.add(utxo);
        }
      }

      // And then remove and add
      for (final symbol in downloaded.keys) {
        final scripthashes_internal = downloaded[symbol]!.keys;

        await _unspentsLock.enterRead();
        // If we have new utxos, get the vouts now.
        final new_utxos = utxos.toSet().difference(
            (_unspentsBySymbol[symbol] ?? <String, Set<ScripthashUnspent>>{})
                .values
                .expand((element) => element)
                .toSet());
        await _unspentsLock.exitRead();

        new_utxos.removeWhere((element) =>
            res.vouts.byTransactionPosition
                .getOne(element.txHash, element.txPos) !=
            null);
        await services.download.history
            .getTransactions(new_utxos.map((x) => x.txHash));

        // New info; clear cache
        await _cachedBySymbolLock.enterWrite();
        _cachedBySymbol.remove(symbol);
        await _cachedBySymbolLock.exitWrite();

        await _unspentsLock.enterWrite();
        scripthashes_internal
            .forEach((x) => _clearUnspentsForScripthash(x, symbol));
        for (final scripthash_internal in scripthashes_internal) {
          _addUnspent(
              symbol: symbol,
              unspents: downloaded[symbol]![scripthash_internal]!,
              subscribe: true);
        }
        await _unspentsLock.exitWrite();
      }
    }
  }

  Future<int> totalConfirmed([String? symbolMaybeNull]) async {
    final symbol = defaultSymbol(symbolMaybeNull);

    await _cachedBySymbolLock.enterRead();
    final cachedResult = _cachedBySymbol[symbol]?[0];
    await _cachedBySymbolLock.exitRead();
    if (cachedResult != null) {
      return cachedResult;
    }

    await _unspentsLock.enterRead();
    final result = _unspentsBySymbol.keys.contains(symbol)
        ? _unspentsBySymbol[symbol]!
            .values // List of iterable of items
            .expand((element) => element) // Flatten the list of iterables
            .fold(
                0,
                (int total, ScripthashUnspent item) =>
                    item.height == 0 ? total : item.value + total)
        : 0;
    await _unspentsLock.exitRead();

    await _cachedBySymbolLock.enterWrite();
    if (!_cachedBySymbol.containsKey(symbol)) {
      _cachedBySymbol[symbol] = [0, 0];
    }
    _cachedBySymbol[symbol]![0] = result;
    await _cachedBySymbolLock.exitWrite();

    return result;
  }

  Future<int> totalUnconfirmed([String? symbolMaybeNull]) async {
    final symbol = defaultSymbol(symbolMaybeNull);

    await _cachedBySymbolLock.enterRead();
    final cachedResult = _cachedBySymbol[symbol]?[1];
    await _cachedBySymbolLock.exitRead();
    if (cachedResult != null) {
      return cachedResult;
    }

    await _unspentsLock.enterRead();
    final result = _unspentsBySymbol.keys.contains(symbol)
        ? _unspentsBySymbol[symbol]!
            .values // List of iterable of items
            .expand((element) => element) // Flatten the list of iterables
            .fold(
                0,
                (int total, ScripthashUnspent item) =>
                    item.height == 0 ? item.value + total : total)
        : 0;
    await _unspentsLock.exitRead();

    await _cachedBySymbolLock.enterWrite();
    if (!_cachedBySymbol.containsKey(symbol)) {
      _cachedBySymbol[symbol] = [0, 0];
    }
    _cachedBySymbol[symbol]![1] = result;
    await _cachedBySymbolLock.exitWrite();

    return result;
  }

  Future<void> assertSufficientFunds(int amount, String? symbol,
      {bool allowUnconfirmed = true}) async {
    var total = await totalConfirmed(defaultSymbol(symbol));
    if (allowUnconfirmed) {
      total += await totalUnconfirmed(defaultSymbol(symbol));
    }
    if (total < amount) {
      throw InsufficientFunds();
    }
  }

  Future<Set<ScripthashUnspent>> getUnspents(String? symbol) async {
    await _unspentsLock.enterRead();
    final result = _unspentsBySymbol[defaultSymbol(symbol)]
            ?.values
            .expand((element) => element)
            .toSet() ??
        <ScripthashUnspent>{};
    await _unspentsLock.exitRead();
    return result;
  }

  Future<Iterable<String>> getSymbols() async {
    await _unspentsLock.enterRead();
    final result = _unspentsBySymbol.keys.toSet();
    await _unspentsLock.exitRead();
    return result;
  }
}
