import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/sats.dart';

part 'state.dart';

class WalletCubit extends Cubit<WalletState> with UpdateHideMixin<WalletState> {
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
  void update({
    bool? active,
    Holding? currency,
    List<Holding>? assets,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(WalletState(
      active: active ?? state.active,
      currency: currency ?? state.currency,
      assets: assets ?? state.assets,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void populateAssets() {
    update(
        currency: Holding(
          name: 'Ravencoin',
          symbol: 'RVN',
          sats: Sats(21),
          metadata: HoldingMetadata(
            divisibility: Divisibility(8),
            reissuable: false,
            supply: Sats.fromCoin(Coin(21000000000)),
          ),
        ),
        assets: []);
    cubits.balance.update(portfolioValue: Fiat(12546.01));
  }

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
