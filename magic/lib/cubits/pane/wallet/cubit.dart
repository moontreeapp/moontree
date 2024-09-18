import 'dart:math';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/domain/utils/extensions/list.dart';
import 'package:magic/presentation/ui/canvas/balance/chips.dart';
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/calls/holdings.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/log.dart';

part 'state.dart';

class WalletCubit extends UpdatableCubit<WalletState> {
  WalletCubit() : super(const WalletState());

  DateTime populatedAt = DateTime.now();

  List<Chips> defaultChips = [
    Chips.all,
    Chips.evrmore,
    Chips.ravencoin,
    Chips.nonzero,
    Chips.currencies,
    Chips.nfts,
    Chips.admintokens,
  ];

  @override
  String get key => 'walletFeed';
  @override
  void reset() => emit(const WalletState());
  @override
  void setState(WalletState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    if (state.active) {
      update(active: false);
    }
    update(active: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    List<Holding>? holdings,
    List<Chips>? chips,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(WalletState(
      active: active ?? state.active,
      holdings: holdings ?? state.holdings,
      chips: chips ?? state.chips,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void toggleChip(Chips chip) {
    if (chip == Chips.all) {
      return update(chips: [Chips.all]);
    }
    final List<Chips> basic = state.chips.contains(chip)
        ? state.chips.where((e) => e != chip).toList()
        : [...state.chips, chip];
    if (basic.isEmpty) {
      return update(chips: [Chips.all]);
    } else if (basic.contains(Chips.all)) {
      basic.remove(Chips.all);
    }
    if (chip == Chips.evrmore) {
      return update(chips: basic.where((e) => e != Chips.ravencoin).toList());
    }
    if (chip == Chips.ravencoin) {
      return update(chips: basic.where((e) => e != Chips.evrmore).toList());
    }
    if (basic.length == defaultChips.length) {
      return update(chips: []);
    }
    update(chips: basic);
  }

  void clearAssets() {
    update(active: false);
    update(holdings: [], active: true);
  }

  Future<bool> populateAssets([int cooldown = 0]) async {
    if (cooldown > 0 &&
        DateTime.now().difference(populatedAt!).inSeconds < cooldown) {
      return false;
    }
    populatedAt = DateTime.now();
    // remember to order by currency first, amount second, alphabetical third
    update(isSubmitting: true);
    see('populateAssets');
    final holdings = setCorrespondingFlag(_sort(_newRateThese(
            symbol: 'EVR',
            rate: await rates.getRateOf('EVR'),
            holdings: await HoldingBalancesCall(
              blockchain: Blockchain.evrmoreMain,
              derivationWallets: cubits.keys.master.derivationWallets,
              keypairWallets: cubits.keys.master.keypairWallets,
            ).call()) +
        _newRateThese(
            symbol: 'RVN',
            rate: await rates.getRateOf('RVN'),
            holdings: await HoldingBalancesCall(
              blockchain: Blockchain.ravencoinMain,
              derivationWallets: cubits.keys.master.derivationWallets,
              keypairWallets: cubits.keys.master.keypairWallets,
            ).call())));
    see('holdings:', holdings, LogColors.magenta);
    if (holdings.isNotEmpty) {
      update(holdings: [], isSubmitting: false);
      update(holdings: holdings, isSubmitting: false);
    }
    if (rates.rvnUsdRate != null) {
      cacheRate(rates.rvnUsdRate!);
    }
    if (rates.evrUsdRate != null) {
      cacheRate(rates.evrUsdRate!);
    }
    return true;
  }

  void populateAssetsSpoof() {
    // remember to order by currency first, amount second, alphabetical third
    update(holdings: [
      for (final index in range(47))
        Holding(
          name: 'Ravencoin',
          symbol: 'RVN',
          blockchain: Blockchain.ravencoinMain,
          sats: Sats(pow(index, index ~/ 4.2) as int),
          metadata: HoldingMetadata(
            divisibility: Divisibility(8),
            reissuable: false,
            supply: Sats.fromCoin(Coin(coin: 21000000000)),
          ),
        ),
    ]);
    cubits.balance.update(portfolioValue: Fiat(12546.01));
  }

  List<Holding> setCorrespondingFlag(List<Holding> holdings) {
    final ret = <Holding>[];
    for (final holding in holdings) {
      see(holding.symbol);
      if (holding.isCurrency) {
        ret.add(holding);
      } else if (holding.isAdmin && mainOf(holding, holdings) != null) {
        ret.add(holding.copyWith(weHaveAdminOrMain: true));
      } else if (!holding.isAdmin && adminOf(holding, holdings) != null) {
        ret.add(holding.copyWith(weHaveAdminOrMain: true));
      } else {
        ret.add(holding);
      }
    }
    return ret;
  }

  /// default sort is by currency type, then by amount, then by alphabetical
  List<Holding> _sort(List<Holding> holdings) =>
      holdings.where((e) => e.isCurrency).toList() +
      holdings.where((e) => !e.isCurrency).toList();

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}

  /// update all the holding with the new rate
  void newRate({required Rate rate}) {
    if (state.holdings.isEmpty) return;
    final holdings = _newRateThese(
        symbol: rate.base.symbol, rate: rate.rate, holdings: state.holdings);
    update(holdings: holdings);
    cacheRate(rate, holdings);
  }

  /// update all the holding with the new rate
  List<Holding> _newRateThese(
      {required String symbol, double? rate, required List<Holding> holdings}) {
    if (holdings.isEmpty || rate == null || rate <= 0) {
      return holdings;
    }
    return holdings
        .map((e) => e.symbol == symbol ? e.copyWith(rate: rate) : e)
        .toList();
  }

  void cacheRate(Rate rate, [List<Holding>? holdings]) {
    // update balance
    cubits.balance.update(
        portfolioValue: Fiat((holdings ?? state.holdings)
            .map((e) => e.coin.toFiat(e.rate).value)
            .sumNumbers()));
    // save to disk, so we can load it on next app start
    storage().then((obj) => obj.write(
        key: StorageKey.rate.key(rate.id),
        value: rate.rate.toStringAsFixed(4)));
  }

  Holding? adminOf(Holding holding, [List<Holding>? overrideHoldings]) =>
      (overrideHoldings ?? state.holdings)
          .firstWhereOrNull((h) => h.symbol == '${holding.symbol}!');

  Holding? mainOf(Holding holding, [List<Holding>? overrideHoldings]) =>
      (overrideHoldings ?? state.holdings).firstWhereOrNull(
          (h) => h.symbol == holding.symbol.replaceAll('!', ''));

  MainAdminPair mainAndAdminOf(Holding holding) => MainAdminPair(
        main: holding.isAdmin ? mainOf(holding) : holding,
        admin: holding.isAdmin ? holding : adminOf(holding),
      );

  Holding getHolding({
    required String symbol,
    required Blockchain blockchain,
  }) =>
      state.holdings.firstWhere((holding) =>
          holding.symbol == symbol && holding.blockchain == blockchain);

  Holding getHoldingFrom({required Holding holding}) =>
      state.holdings.firstWhere((h) =>
          h.symbol == holding.symbol && h.blockchain == holding.blockchain);
}

class MainAdminPair {
  final Holding? main;
  final Holding? admin;
  const MainAdminPair({required this.main, required this.admin});
  bool get full => main != null && admin != null;
}
