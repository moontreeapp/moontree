import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_back/server/serverv2_client.dart';
import 'package:client_front/infrastructure/repos/transaction.dart';
import 'package:client_front/application/common.dart';
import 'package:client_front/application/location/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class TransactionViewCubit extends Cubit<TransactionViewState>
    with SetCubitMixin {
  TransactionViewCubit() : super(TransactionViewState.initial()) {
    Future.delayed(Duration(seconds: 10)).then((_) => init());
  }

  @override
  Future<void> reset() async => emit(TransactionViewState.initial());

  @override
  TransactionViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    TransactionDetailsView? transactionView,
    ByteData? ranHash,
    bool? isSubmitting,
  }) {
    emit(state.load(
      transactionView: transactionView,
      ranHash: ranHash,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    // alternative to a listener, setup a callback on the location cubit
    components.cubits.location.hooks
        .add((LocationCubitState state, LocationCubitState next) {
      if (state.path == '/wallet/holding' &&
          next.path == '/wallet/holding/transaction') {
        reset();
      }
    });
  }

  Future<void> setTransactionDetails({
    required ByteData hash,
    bool force = false,
  }) async {
    if (force || (state.ranHash != hash && !state.isSubmitting)) {
      set(transactionView: null, isSubmitting: true);
      set(
        transactionView: await TransactionDetailsRepo(hash: hash).get(),
        ranHash: hash,
        isSubmitting: false,
      );
    }
  }

  void clearCache() => set(transactionView: null);
}
