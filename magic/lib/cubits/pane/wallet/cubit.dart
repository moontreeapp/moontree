import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/sats.dart';
import 'package:magic/presentation/utils/range.dart';

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
    List<Holding>? assets,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(WalletState(
      active: active ?? state.active,
      assets: assets ?? state.assets,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void populateAssets() {
    update(assets: [
      //for (final index in range(47))
      for (final index in range(3))
        Holding(
          name: 'Ravencoin',
          symbol: 'RVN',
          root: 'RVN',
          sats: Sats(pow(index, index ~/ 4.2) as int),
          metadata: HoldingMetadata(
            divisibility: Divisibility(8),
            reissuable: false,
            supply: Sats.fromCoin(Coin(21000000000)),
          ),
        ),
    ]);

    cubits.balance.update(portfolioValue: Fiat(12546.01));
  }

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
