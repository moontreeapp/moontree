import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/holding.dart';

part 'state.dart';

class WalletFeedCubit extends Cubit<WalletFeedState>
    with UpdateSectionMixin<WalletFeedState> {
  WalletFeedCubit() : super(const WalletFeedState());
  @override
  void reset() => emit(const WalletFeedState());
  @override
  void setState(WalletFeedState state) => emit(state);
  @override
  void hide() => update();

  @override
  void update({
    Holding? currency,
    List<Holding>? assets,
    bool? isSubmitting,
  }) {
    emit(WalletFeedState(
      currency: currency ?? state.currency,
      assets: assets ?? state.assets,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void populateAssets() => update(
      currency: Holding(
        name: 'Ravencoin',
        symbol: 'RVN',
        sats: Sat(21),
        metadata: HoldingMetadata(
          divisibility: Divisibility(8),
          reissuable: false,
          supply: Sat.fromCoin(Coin(21000000000)),
        ),
      ),
      assets: []);

  // todo pagenate list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
