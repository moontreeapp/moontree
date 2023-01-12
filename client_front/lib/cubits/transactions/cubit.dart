import 'dart:math';

import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_front/services/client/asset_metadata.dart';
import 'package:flutter/material.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/services/client/transactions.dart';
import 'package:moontree_utils/extensions/bytedata.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:client_back/client_back.dart';
import 'package:client_front/cubits/parents.dart';
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
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    Wallet? ranWallet,
    Security? ranSecurity,
    int? ranHeight,
    bool? isSubmitting,
  }) {
    emit(submitting());
    emit(state.load(
      transactionViews: transactionViews,
      metadataView: metadataView,
      wallet: wallet,
      security: security,
      ranWallet: ranWallet,
      ranSecurity: ranSecurity,
      ranHeight: ranHeight,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> setTransactionViews({bool force = false}) async {
    if (force ||
        state.wallet != state.ranWallet ||
        state.security != state.ranSecurity) {
      set(
        transactionViews: await discoverTransactionHistory(
          wallet: state.wallet,
          security: state.security,
        ),
        ranWallet: state.wallet,
        ranSecurity: state.security,
        isSubmitting: false,
      );
    }
  }

  Future<void> addSetTransactionViews() async {
    if (!state.isSubmitting &&
        (state.ranHeight == null ||
            state.lowestHeight == null ||
            state.ranHeight! > state.lowestHeight!)) {
      submitting();
      final batch = await discoverTransactionHistory(
          wallet: state.wallet,
          security: state.security,
          height: state.lowestHeight);
      if (batch.isNotEmpty) {
        set(
          transactionViews: state.transactionViews + batch,
          ranWallet: state.wallet,
          ranSecurity: state.security,
          ranHeight: state.lowestHeight,
          isSubmitting: false,
        );
      } else {
        // set something that it's done
        set(
          transactionViews: state.transactionViews,
          ranWallet: state.wallet,
          ranSecurity: state.security,
          ranHeight: state.lowestHeight,
          isSubmitting: false,
        );
      }
    }
  }

  Future<void> setMetadataView({bool force = false}) async {
    if (force || state.metadataView == null) {
      submitting();
      set(
        metadataView: (await discoverAssetMetadataHistory(
          wallet: state.wallet,
          security: state.security,
        ))
            .firstOrNull,
        isSubmitting: false,
      );
    }
  }

  bool get nullCacheView {
    //final Asset? securityAsset = state.security.asset;
    final AssetMetadata? securityAsset = state.metadataView;
    return securityAsset == null;
  }

  void clearCache() => set(
        transactionViews: <TransactionView>[],
        metadataView: null,
      );
}
