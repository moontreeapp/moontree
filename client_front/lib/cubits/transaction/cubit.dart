import 'dart:typed_data';

import 'package:client_back/server/serverv2_client.dart';
import 'package:client_front/services/client/transaction.dart';
import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_front/services/client/asset_metadata.dart';
import 'package:flutter/material.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/services/client/transactions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:client_back/client_back.dart';
import 'package:client_front/cubits/parents.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class TransactionViewCubit extends Cubit<TransactionViewState>
    with SetCubitMixin {
  TransactionViewCubit() : super(TransactionViewState.initial());

  @override
  Future<void> reset() async => emit(TransactionViewState.initial());

  @override
  TransactionViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(submitting());
    emit(state);
  }

  @override
  void set({
    TransactionDetailsView? transactionView,
    bool? isSubmitting,
  }) {
    emit(submitting());
    emit(state.load(
      transactionView: transactionView,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> setTransactionDetails({
    required ByteData hash,
    bool force = false,
  }) async =>
      force || state.transactionView == null
          ? () async {
              set(transactionView: null, isSubmitting: true);
              set(
                transactionView: await discoverTransactionDetails(hash: hash),
                isSubmitting: false,
              );
            }()
          : () {}();

  void clearCache() => set(transactionView: null);
}
