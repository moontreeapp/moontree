import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/sats.dart';

part 'state.dart';

class TransactionsCubit extends Cubit<TransactionsState>
    with UpdateHideMixin<TransactionsState> {
  TransactionsCubit() : super(const TransactionsState());
  @override
  String get key => 'transactions';
  @override
  void reset() => emit(const TransactionsState());
  @override
  void setState(TransactionsState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void update({
    bool? active,
    bool? disposed,
    Holding? currency,
    List<Holding>? assets,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(TransactionsState(
      active: active ?? state.active,
      currency: currency ?? state.currency,
      assets: assets ?? state.assets,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void populateAssets() => update(
      currency: Holding(
        name: 'Ravencoin',
        symbol: 'RVN',
        root: 'RVN',
        sats: Sats(21),
        metadata: HoldingMetadata(
          divisibility: Divisibility(8),
          reissuable: false,
          supply: Sats.fromCoin(Coin(21000000000)),
        ),
      ),
      assets: []);

  // todo pagenae list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
