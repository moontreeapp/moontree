import 'dart:async';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:raven_back/utilities/search.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

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

  List<Balance> unspentBalances = <Balance>[];

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
      final new_utxos = await _unspentsLock.read(() {
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

      if (new_utxos.isNotEmpty) {
        services.download.history.unspentsTxsFetchFirst
            .add(new_utxos.map((x) => x.txHash));
      }

      // New info; clear cache
      await _cachedBySymbolLock.write(() {
        _cachedBySymbol.remove(rvn);
      });
      await _unspentsLock.write(() {
        finalScripthashes.forEach((x) => _clearUnspentsForScripthash(x, rvn));
        _addUnspent(symbol: rvn, unspents: utxos);
      });
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
        final new_utxos = await _unspentsLock.read(() {
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

        if (new_utxos.isNotEmpty) {
          services.download.history.unspentsTxsFetchFirst
              .add(new_utxos.map((x) => x.txHash));
        }

        await _cachedBySymbolLock.write(() {
          _cachedBySymbol.remove(symbol);
        });
        await _unspentsLock.write(() {
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
    scripthashesChecked = await _scripthashesCheckedLock.write(() {
      _scripthashesChecked.addAll(finalScripthashes);
      return _scripthashesChecked.length;
    });
    uniqueAssets = await _unspentsLock.read(() {
      return _unspentsBySymbol.length;
    });
    await _updateUnspentsBalance();
    // Balances are based on unspents now
    await services.balance.recalculateAllBalances();
    streams.wallet.unspentsCallback.add(null);
  }

  Future<void> _updateUnspentsBalance() async {
    final tempBalances = <Balance>[];
    final symbols = await _unspentsLock.read(() {
      return _unspentsBySymbol.keys.toSet();
    });
    for (final symbol in symbols) {
      // TODO: User decides how to sort?
      binaryInsert(
          list: tempBalances,
          value: Balance(
              walletId: res.settings.currentWalletId,
              security: symbol == res.securities.RVN.symbol
                  ? res.securities.RVN
                  : Security(
                      symbol: symbol, securityType: SecurityType.RavenAsset),
              confirmed: await total(symbol, TotalType.confirmed),
              unconfirmed: await total(symbol, TotalType.unconfirmed)),
          comp: (first, second) =>
              first.security.symbol.compareTo(second.security.symbol));
    }
    // Update pointer for async ness
    unspentBalances = tempBalances;
  }

  Future<int> total([String? symbolMaybeNull, TotalType? totalType]) async {
    totalType = totalType ?? TotalType.confirmed;
    final totalIndex = totalType == TotalType.confirmed ? 0 : 1;
    final symbol = defaultSymbol(symbolMaybeNull);
    final cachedResult = await _cachedBySymbolLock.read(() {
      return _cachedBySymbol[symbol]?[totalIndex];
    });
    if (cachedResult != null) {
      return cachedResult;
    }
    final result = await _unspentsLock.read(() {
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
    await _cachedBySymbolLock.write(() {
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
    return await _unspentsLock.read(() {
      return _unspentsBySymbol[defaultSymbol(symbol)]
              ?.values
              .expand((element) => element)
              .toSet() ??
          <ScripthashUnspent>{};
    });
  }

  Future<Iterable<String>> getSymbols() async {
    return await _unspentsLock.read(() {
      return _unspentsBySymbol.keys.toSet();
    });
  }

  Future<void> clearData() async {
    await _unspentsLock.write(() {
      _unspentsBySymbol.clear();
    });
    await _cachedBySymbolLock.write(() {
      _cachedBySymbol.clear();
    });
    await _scripthashesCheckedLock.write(() {
      _scripthashesChecked.clear();
    });
    unspentBalances = [];
    scripthashesChecked = 0;
    uniqueAssets = 0;
  }
}
