import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/calls/holdings.dart';

part 'state.dart';

class WalletCubit extends UpdatableCubit<WalletState> {
  WalletCubit() : super(const WalletState());
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
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(WalletState(
      active: active ?? state.active,
      holdings: holdings ?? state.holdings,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  Future<void> populateAssets() async {
    // remember to order by currency first, amount second, alphabetical third
    update(isSubmitting: true);
    update(
        holdings: await HoldingBalancesCall(
          blockchain: Blockchain.ravencoinMain,
          mnemonicWallets: cubits.keys.master.mnemonicWallets,
          keypairWallets: cubits.keys.master.keypairWallets,
        ).call(),
        isSubmitting: false);
    cubits.balance.update(portfolioValue: Fiat(12546.01));
  }

  void populateAssetsSpoof() {
    // remember to order by currency first, amount second, alphabetical third
    update(holdings: [
      for (final index in range(47))
        Holding(
          name: 'Ravencoin',
          symbol: 'RVN',
          root: 'RVN',
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

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
