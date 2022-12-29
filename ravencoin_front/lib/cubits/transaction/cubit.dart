import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/server/src/protocol/comm_transaction_view.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/cubits/parents.dart';

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class TransactionsViewCubit extends Cubit<TransactionsViewState>
    with SetCubitMixin {
  TransactionsViewCubit() : super(TransactionsViewState.initial());

  @override
  Future<void> reset() async => emit(TransactionsViewState.initial());

  @override
  TransactionsViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(submitting());
    emit(state);
  }

  @override
  void set({
    List<TransactionView>? transactionViews,
    bool? isSubmitting,
  }) {
    emit(submitting());
    emit(state.load(
      transactionViews: transactionViews,
      isSubmitting: isSubmitting,
    ));
  }

  //void submit() async {
  //  emit(await submitSend());
  //}
}
