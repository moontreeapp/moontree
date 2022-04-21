import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

enum LockType { read, write }
enum TotalType { confirmed, unconfirmed }

/// we use the electrum server directly for determining our UTXO set
/// This gets erased when we swap wallets
class UnspentService {
  // "Security name" -> address -> {unspents}
  // This can be concurrently modified while we iterate over keys, i.e. recalc balances
  final Map<String, Map<String, Set<ScripthashUnspent>>> _unspentsBySymbol = {};
  final _unspentsLock = ReaderWriterLock();

  final Map<String, List<int?>> _cachedBySymbol = {};
  final _cachedBySymbolLock = ReaderWriterLock();

  final Set<String> _scripthashesChecked = {};
  final _scripthashesCheckedLock = ReaderWriterLock();
  int scripthashesChecked = 0;
  int uniqueAssets = 0;

  Future<T> lockScope<T>({
    required T Function() fn,
    ReaderWriterLock? lock,
    LockType lockType = LockType.read,
  }) async {
    lock = lock ?? _unspentsLock;
    lockType == LockType.write
        ? await lock.enterWrite()
        : await lock.enterRead();
    var x = fn();
    lockType == LockType.write ? await lock.exitWrite() : await lock.exitRead();
    return x;
  }

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
    final finalScripthashes = defaultScripthashes(scripthashes);
    final rvn = res.securities.RVN.symbol;
    if (updateRVN ?? true) {
      var utxos = (await services.client.client!.getUnspents(finalScripthashes))
          .expand((i) => i);

      // Wipe relevant unspents and re-add
      // If we have new utxos, get the vouts now.
      final new_utxos = await lockScope(fn: () {
        return utxos.toSet().difference(
            (_unspentsBySymbol[rvn] ?? <String, Set<ScripthashUnspent>>{})
                .values
                .expand((element) => element)
                .toSet());
      });
      new_utxos.removeWhere((element) =>
          res.vouts.byTransactionPosition
              .getOne(element.txHash, element.txPos) !=
          null);
      await services.download.history
          .getTransactions(new_utxos.map((x) => x.txHash));
      // New info; clear cache
      await lockScope(
        lock: _cachedBySymbolLock,
        lockType: LockType.write,
        fn: () {
          _cachedBySymbol.remove(rvn);
        },
      );
      await lockScope(
        lockType: LockType.write,
        fn: () {
          finalScripthashes.forEach((x) => _clearUnspentsForScripthash(x, rvn));
          _addUnspent(symbol: rvn, unspents: utxos);
        },
      );
    }
    if (!(updateRVN ?? false)) {
      var utxos =
          (await services.client.client!.getAssetUnspents(finalScripthashes))
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

        // If we have new utxos, get the vouts now.
        final new_utxos = await lockScope(fn: () {
          return utxos.toSet().difference(
              (_unspentsBySymbol[symbol] ?? <String, Set<ScripthashUnspent>>{})
                  .values
                  .expand((element) => element)
                  .toSet());
        });

        new_utxos.removeWhere((element) =>
            res.vouts.byTransactionPosition
                .getOne(element.txHash, element.txPos) !=
            null);
        await services.download.history
            .getTransactions(new_utxos.map((x) => x.txHash));

        await lockScope(
            lock: _cachedBySymbolLock,
            lockType: LockType.write,
            fn: () {
              _cachedBySymbol.remove(symbol);
            });
        await lockScope(
            lockType: LockType.write,
            fn: () {
              // New info; clear cache
              scripthashes_internal
                  .forEach((x) => _clearUnspentsForScripthash(x, symbol));
              for (final scripthash_internal in scripthashes_internal) {
                _addUnspent(
                    symbol: symbol,
                    unspents: downloaded[symbol]![scripthash_internal]!,
                    subscribe: true);
              }
            });
      }
    }
    scripthashesChecked = await lockScope(
        lock: _scripthashesCheckedLock,
        lockType: LockType.write,
        fn: () {
          _scripthashesChecked.addAll(finalScripthashes);
          return _scripthashesChecked.length;
        });
    uniqueAssets = await lockScope(fn: () {
      return _unspentsBySymbol.length;
    });
  }

  Future<int> total([String? symbolMaybeNull, TotalType? totalType]) async {
    totalType = totalType ?? TotalType.confirmed;
    final totalIndex = totalType == TotalType.confirmed ? 0 : 1;
    final symbol = defaultSymbol(symbolMaybeNull);
    final cachedResult = await lockScope(
        lock: _cachedBySymbolLock,
        lockType: LockType.read,
        fn: () {
          return _cachedBySymbol[symbol]?[totalIndex];
        });
    if (cachedResult != null) {
      return cachedResult;
    }
    final result = await lockScope(fn: () {
      return _unspentsBySymbol.keys.contains(symbol)
          ? _unspentsBySymbol[symbol]!
              .values // List of iterable of items
              .expand((element) => element) // Flatten the list of iterables
              .fold(
                  0,
                  (int total, ScripthashUnspent item) =>
                      totalType == TotalType.confirmed
                          ? item.height == 0
                              ? total
                              : item.value + total
                          : item.height == 0
                              ? item.value + total
                              : total)
          : 0;
    });
    await lockScope(
        lock: _cachedBySymbolLock,
        lockType: LockType.write,
        fn: () {
          if (!_cachedBySymbol.containsKey(symbol)) {
            _cachedBySymbol[symbol] = [null, null];
          }
          _cachedBySymbol[symbol]![totalIndex] = result;
        });
    return result;
  }

  Future<int> totalConfirmed([String? symbolMaybeNull]) async {
    return total(symbolMaybeNull, TotalType.confirmed);
  }

  Future<int> totalUnconfirmed([String? symbolMaybeNull]) async {
    return total(symbolMaybeNull, TotalType.unconfirmed);
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
    return await lockScope(fn: () {
      return _unspentsBySymbol[defaultSymbol(symbol)]
              ?.values
              .expand((element) => element)
              .toSet() ??
          <ScripthashUnspent>{};
    });
  }

  Future<Iterable<String>> getSymbols() async {
    return await lockScope(fn: () {
      return _unspentsBySymbol.keys.toSet();
    });
  }

  Future<void> clearData() async {
    await lockScope(
        lockType: LockType.write,
        fn: () {
          _unspentsBySymbol.clear();
        });
    await lockScope(
        lock: _cachedBySymbolLock,
        lockType: LockType.write,
        fn: () {
          _cachedBySymbol.clear();
        });
    await lockScope(
        lock: _scripthashesCheckedLock,
        lockType: LockType.write,
        fn: () {
          _scripthashesChecked.clear();
        });
    scripthashesChecked = 0;
    uniqueAssets = 0;
  }
}
