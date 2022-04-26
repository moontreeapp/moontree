import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:raven_back/utilities/search.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

enum ValueType { confirmed, unconfirmed }

/// we use the electrum server directly for determining our UTXO set
/// This gets erased when we swap wallets
class UnspentService {
  // "Security name" -> scripthash -> {unspents}
  // This can be concurrently modified while we iterate over keys, i.e. recalc balances
  final Map<String, Map<String, Set<ScripthashUnspent>>> _unspentsBySymbol = {};
  final _unspentsLock = ReaderWriterLock();

  final Map<String, Map<String, List<int>>> _cachedByWalletAndSymbol = {};
  final _cachedBySymbolLock = ReaderWriterLock();

  final Set<String> _scripthashesChecked = {};

  final _scripthashesCheckedLock = ReaderWriterLock();
  int scripthashesChecked = 0;
  int uniqueAssets = 0;

  Map<String, Iterable<Balance>> unspentBalancesByWalletId =
      <String, Iterable<Balance>>{};

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

        // Don't use empty vins
        if (unspent.value != 0) {
          _unspentsBySymbol[symbol]![unspent.scripthash]!.add(unspent);
        }
      }
    }
  }

  Future<void> pull({Iterable<String>? scripthashes, bool? updateRVN}) async {
    final finalScripthashes = defaultScripthashes(scripthashes);
    final rvn = res.securities.RVN.symbol;

    // Clear all cached unspents & redownload
    await _unspentsLock.write(() {
      for (final symbol in _unspentsBySymbol.keys) {
        finalScripthashes
            .forEach((x) => _clearUnspentsForScripthash(x, symbol));
      }
    });

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
        for (final walletId in _cachedByWalletAndSymbol.keys) {
          _cachedByWalletAndSymbol[walletId]!.remove(rvn);
        }
      });
      await _unspentsLock.write(() {
        _addUnspent(symbol: rvn, unspents: utxos);
      });
    }
    if (!(updateRVN ?? false)) {
      var utxos =
          (await services.client.client!.getAssetUnspents(finalScripthashes))
              .expand((i) => i);

      // Parse it into something more digestable
      // symbol -> scripthash -> unspents
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
          for (final walletId in _cachedByWalletAndSymbol.keys) {
            _cachedByWalletAndSymbol[walletId]!.remove(symbol);
          }
        });
        await _unspentsLock.write(() {
          _addUnspent(
              symbol: symbol,
              unspents: downloaded[symbol]!.values.expand((element) => element),
              subscribe: true);
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
    await _updateUnspentsBalances();
    // Balances are based on unspents now
    await services.balance.recalculateAllBalances();
    streams.wallet.unspentsCallback.add(null);
  }

  Future<void> _updateUnspentsBalances() async {
    final tempBalances = <String, Iterable<Balance>>{};
    final symbols = await _unspentsLock.read(() {
      return _unspentsBySymbol.keys.toSet();
    });
    for (final wallet in res.wallets.data) {
      print('Recalculating balances for ${wallet.id}');

      final walletId = wallet.id;
      final tempList = <Balance>[];
      for (final symbol in symbols) {
        // TODO: User decides how to sort?
        final confirmed = await _total(walletId, symbol, ValueType.confirmed);
        final unconfirmed =
            await _total(walletId, symbol, ValueType.unconfirmed);

        // TODO: If we eventually want to show assets that a user spent all of,
        // This will need to change (more likely we will need to incorporate a
        // history check)
        if (confirmed + unconfirmed > 0) {
          binaryInsert(
              list: tempList,
              value: Balance(
                  walletId: res.settings.currentWalletId,
                  security: symbol == res.securities.RVN.symbol
                      ? res.securities.RVN
                      : Security(
                          symbol: symbol,
                          securityType: SecurityType.RavenAsset),
                  confirmed: confirmed,
                  unconfirmed: unconfirmed),
              comp: (first, second) =>
                  first.security.symbol.compareTo(second.security.symbol));
        }
      }
      tempBalances[walletId] = tempList;
    }
    // Update pointer for async ness
    unspentBalancesByWalletId = tempBalances;
  }

  Future<int> _total(String walletId,
      [String? symbolMaybeNull, ValueType? totalType]) async {
    totalType = totalType ?? ValueType.confirmed;
    final totalIndex = totalType == ValueType.confirmed ? 0 : 1;
    final symbol = defaultSymbol(symbolMaybeNull);
    final cachedResult = await _cachedBySymbolLock.read(() {
      return _cachedByWalletAndSymbol[walletId]?[symbol]?[totalIndex];
    });
    if (cachedResult != null) {
      return cachedResult;
    }

    // Recalc
    final result = await _unspentsLock.read(() {
      return _unspentsBySymbol.keys.contains(symbol)
          ? _unspentsBySymbol[symbol]!
              .values // List of iterable of items
              .expand((element) => element) // Flatten the list of iterables
              .fold(<String, List<int>>{},
                  (Map<String, List<int>> gatherer, ScripthashUnspent unspent) {
              final address =
                  res.addresses.byScripthash.getOne(unspent.scripthash);
              if (address == null) {
                throw StateError(
                    'We are tracking a scripthash that has no associated address');
              }

              var walletId = address.walletId;

              if (!gatherer.containsKey(walletId)) {
                gatherer[walletId] = [0, 0];
              }

              if (unspent.height > 0) {
                // Confirmed
                gatherer[walletId]![0] = gatherer[walletId]![0] + unspent.value;
              } else {
                // Mempool
                gatherer[walletId]![1] = gatherer[walletId]![1] + unspent.value;
              }

              return gatherer;
            })
          : null;
    });

    return await _cachedBySymbolLock.write(() {
      if (result == null) {
        // We don't have anything on this but we're asking for it?
        // Just cache 0 for a quick return
        if (!_cachedByWalletAndSymbol.containsKey(walletId)) {
          _cachedByWalletAndSymbol[walletId] = <String, List<int>>{};
        }
        _cachedByWalletAndSymbol[walletId]![symbol] = [0, 0];
      } else {
        for (final walletId in result.keys) {
          if (!_cachedByWalletAndSymbol.containsKey(walletId)) {
            _cachedByWalletAndSymbol[walletId] = <String, List<int>>{};
          }
          _cachedByWalletAndSymbol[walletId]![symbol] = result[walletId]!;
        }
      }
      // We recalc all relevant outpoints of a symbol, but if a symbol wasn't
      // a part of the wallet, we don't catch it.
      // Do another check here
      final res = _cachedByWalletAndSymbol[walletId]![symbol];
      if (res == null) {
        // Cache as 0
        _cachedByWalletAndSymbol[walletId]![symbol] = [0, 0];
        return 0;
      } else {
        return res[totalIndex];
      }
    });
  }

  Future<int> totalConfirmed(String walletId, [String? symbolMaybeNull]) async {
    return _total(walletId, symbolMaybeNull, ValueType.confirmed);
  }

  Future<int> totalUnconfirmed(String walletId,
      [String? symbolMaybeNull]) async {
    return _total(walletId, symbolMaybeNull, ValueType.unconfirmed);
  }

  Future<void> assertSufficientFunds(
      String walletId, int amount, String? symbol,
      {bool allowUnconfirmed = true}) async {
    var total = await totalConfirmed(walletId, defaultSymbol(symbol));
    if (allowUnconfirmed) {
      total += await totalUnconfirmed(walletId, defaultSymbol(symbol));
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
      _cachedByWalletAndSymbol.clear();
    });
    await _scripthashesCheckedLock.write(() {
      _scripthashesChecked.clear();
    });
    unspentBalancesByWalletId = {};
    scripthashesChecked = 0;
    uniqueAssets = 0;
  }
}

class Unspent with EquatableMixin {
  Address address;
  String transactionId;
  int position;
  int value;
  ValueType valueType;
  String symbol;

  Unspent({
    required this.address,
    required this.transactionId,
    required this.position,
    required this.value,
    required this.valueType,
    this.symbol = 'RVN',
  });

  @override
  List<Object> get props =>
      [address, transactionId, position, value, valueType, symbol];

  factory Unspent.fromScripthashUnspent(ScripthashUnspent scripthashUnspent) {
    return Unspent(
      address: res.addresses.primaryIndex.getOne(scripthashUnspent.scripthash)!,
      transactionId: scripthashUnspent.txHash,
      position: scripthashUnspent.txPos,
      valueType: scripthashUnspent.height > 0
          ? ValueType.confirmed
          : ValueType.unconfirmed,
      value: scripthashUnspent.value,
      symbol: scripthashUnspent.symbol ?? res.securities.RVN.symbol,
    );
  }

  @override
  String toString() {
    return 'Unspent(address: $address, transactionId: $transactionId, '
        'position: $position, valueType: $valueType, value: $value, '
        'symbol: $symbol)';
  }
}
