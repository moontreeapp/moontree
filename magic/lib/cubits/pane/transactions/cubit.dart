import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/sats.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/utils/range.dart';

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
    Holding? asset,
    // should be Transaction then we convert to a display object in the ui or state.
    List<TransactionDisplay>? transactions,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(TransactionsState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      transactions: transactions ?? state.transactions,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void populate() => update(
          asset: Holding(
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
          transactions: [
            for (final index in range(6))
              TransactionDisplay(
                  incoming: Random().nextInt(2) == 0,
                  when: DateTime.now(),
                  sats: Sats(() {
                    final x = pow(index, index) as int;
                    if (x > 0 && x < 2100000000000000000) {
                      return x;
                    }
                    return index;
                  }()))
          ]);

  // todo pagenae list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
