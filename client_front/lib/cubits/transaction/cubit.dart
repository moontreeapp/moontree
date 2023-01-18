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
  String? priorPage;

  TransactionViewCubit() : super(TransactionViewState.initial()) {
    init();
  }

  @override
  Future<void> reset() async => emit(TransactionViewState.initial());

  @override
  TransactionViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    //emit(submitting());
    emit(state);
  }

  @override
  void set({
    TransactionDetailsView? transactionView,
    ByteData? ranHash,
    bool? isSubmitting,
  }) {
    //emit(submitting());
    emit(state.load(
      transactionView: transactionView,
      ranHash: ranHash,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    streams.app.page.listen((String value) {
      if (value == 'Transactions' && priorPage == 'Transaction') {
        reset();
      }
      priorPage = value;
    });
  }

  Future<void> setTransactionDetails({
    required ByteData hash,
    bool force = false,
  }) async =>
      force || (state.ranHash != hash && !state.isSubmitting)
          ? () async {
              print('calling');
              set(transactionView: null, isSubmitting: true);
              set(
                transactionView: await discoverTransactionDetails(hash: hash),
                ranHash: hash,
                isSubmitting: false,
              );
            }()
          : () {
              print('state.ranHash != hash && !state.isSubmitting');
              print('${state.ranHash != hash} && !${state.isSubmitting}');
              print('not calling');
            }();

  void clearCache() => set(transactionView: null);
}
