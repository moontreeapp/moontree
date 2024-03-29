import 'dart:math';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_asset_metadata_response.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/infrastructure/repos/transactions.dart';
import 'package:client_front/infrastructure/repos/mempool_transactions.dart';
import 'package:client_front/infrastructure/repos/asset_metadata.dart';
import 'package:client_front/infrastructure/repos/circulating_sats.dart';
import 'package:client_front/application/common.dart';
import 'package:client_front/application/infrastructure/location/cubit.dart';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class WalletHoldingViewCubit extends Cubit<WalletHoldingViewState>
    with SetCubitMixin {
  WalletHoldingViewCubit() : super(WalletHoldingViewState.initial()) {
    Future.delayed(Duration(seconds: 10)).then((_) => init());
  }

  @override
  Future<void> reset() async => emit(WalletHoldingViewState.initial());

  @override
  WalletHoldingViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    List<TransactionView>? transactionViews,
    List<TransactionView>? mempoolViews,
    AssetMetadataResponse? metadataView,
    Wallet? wallet,
    Security? security,
    bool? end,
    Wallet? ranWallet,
    Security? ranSecurity,
    int? ranHeight,
    bool? isSubmitting,
  }) {
    emit(state.load(
      transactionViews: transactionViews,
      mempoolViews: mempoolViews,
      metadataView: metadataView,
      wallet: wallet,
      security: security,
      end: end,
      ranWallet: ranWallet,
      ranSecurity: ranSecurity,
      ranHeight: ranHeight,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    components.cubits.location.hooks
        .add((LocationCubitState state, LocationCubitState next) {
      if (state.path == '/wallet/holdings' && next.path == '/wallet/holding') {
        reset();
      }
    });
  }

  /// Here we have logic to avoid populating transactionViews in the event
  /// that we have navigated away from the page in the meantime (cleared the
  /// contents of the cubit)
  bool get cleared => state.ranWallet == null;

  Future<void> setInitial({bool force = false}) async {
    setMempoolTransactionViews(force: force);
    setTransactionViews(force: force);
    Future.delayed(slideDuration).then((_) {
      setMetadataView(force: force);
    });
  }

  Future<void> setMetadataView({bool force = false}) async {
    if (force || state.metadataView == null) {
      final checkCleared = state.ranWallet != null;
      submitting();
      final metadataView = (await AssetMetadataHistoryRepo(
        security: state.security,
      ).fetch());
      if (checkCleared && cleared) {
        return;
      }
      if (state.security.isCoin) {
        metadataView.totalSupply = (await CirculatingSatsRepo(
          security: state.security,
        ).get())
            .value;
      }
      set(
        metadataView: metadataView,
        isSubmitting: false,
      );
    }
  }

  Future<void> setMempoolTransactionViews({bool force = false}) async {
    if (force || state.mempoolViews.isEmpty) {
      submitting();
      final mempoolViews = await MempoolTransactionHistoryRepo(
        wallet: state.wallet,
        security: state.security,
      ).fetch(only: true);
      set(
        mempoolViews: mempoolViews.toList(),
        isSubmitting: false,
      );
    }
  }

  Future<void> setTransactionViews({bool force = false}) async {
    if (force ||
        state.wallet != state.ranWallet ||
        state.security != state.ranSecurity) {
      submitting();
      final checkCleared = state.ranWallet != null;
      final transactionViews = await TransactionHistoryRepo(
        wallet: state.wallet,
        security: state.security,
      ).fetch(only: true);
      if (checkCleared && cleared) {
        return;
      }
      set(
        transactionViews: transactionViews.toList(),
        ranWallet: state.wallet,
        ranSecurity: state.security,
        isSubmitting: false,
      );
    }
  }

  Future<void> addSetTransactionViews({bool force = false}) async {
    if (force ||
        (!state.isSubmitting &&
            (state.ranHeight == null ||
                state.lowestHeight == null ||
                state.ranHeight! > state.lowestHeight!))) {
      final checkCleared = state.ranWallet != null;
      submitting();
      final batch = await TransactionHistoryRepo(
              wallet: state.wallet,
              security: state.security,
              height: state.lowestHeight)
          .fetch(only: true);
      /*
      kralverde — Today at 9:06 AM
        if you look at the actual vins from https://evr.cryptoscope.io/api/getrawtransaction/?txid=df745a3ee1050a9557c3b449df87bdd8942980dff365f7f5a93bc10cb1080188&decode=1 they will match
        the client side fix would just be to maintain a set of heights already seen
        if the vouttransactionstructthingie's height is in that set, ignore it
      meta stack — Today at 9:08 AM
        but couldn't we have multiple transactions at the same height?
      kralverde — Today at 9:08 AM
        yes, but the logic of the endpoint will return all values at the lowest height
        so if you receive that lowest height, you can be sure that you recieved all of the txs from that lowest height
      meta stack — Today at 9:09 AM
        ah, so only compare against the list that was generated before the current batch?
      kralverde — Today at 9:09 AM
        it would have to be against the entire list, but yes
        just keep a set<int>, if x.height in set, ignore, else insert x.height into the set + add to the ui
      */
      /// by individual transaction solution - this clears up all the semi-duplicate erroneous inputs but I think it also removes potentially good transactions as we could have multiple unrelated transactions in the same height and this would filter those out too...
      /// preferring this one as multiple transactions at the same height is a more rare occurance I think.
      Set heights = <int>{};
      final len = state.transactionViews.length;
      int i = 0;
      var newTransactionViews = <TransactionView>[];
      newTransactionViews.addAll(state.transactionViews);
      for (final x in state.transactionViews + batch.toList()) {
        if (!heights.contains(x.height)) {
          heights.add(x.height);
          // add batch item
          if (i > len) {
            newTransactionViews.add(x);
          }
        }
        i++;
      }

      /// by batch solution - this clears up the semi-duplicate erroneous inputs that did not happen in the same batch, but not the ones that do happen in the same batch:
      //final priorHeights = state.transactionViews.map((e) => e.height).toSet();
      //final limitedBatch = batch.where((e) => !priorHeights.contains(e.height));
      //final newTransactionViews = state.transactionViews + limitedBatch.toList();

      if (checkCleared && cleared) {
        return;
      }

      /// finally we update the state
      if (batch.isNotEmpty) {
        set(
          transactionViews: newTransactionViews,
          ranWallet: state.wallet,
          ranSecurity: state.security,
          ranHeight: state.lowestHeight,
          isSubmitting: false,
        );
      } else {
        set(
          transactionViews: state.transactionViews,
          end: true, // indicates end of transaction list for view
          ranWallet: state.wallet,
          ranSecurity: state.security,
          ranHeight: state.lowestHeight,
          isSubmitting: false,
        );
      }
    }
  }

  bool get nullCacheView {
    //final Asset? securityAsset = state.security.asset;
    final AssetMetadataResponse? securityAsset = state.metadataView;
    return securityAsset == null;
  }

  void clearCache() => set(
        transactionViews: <TransactionView>[],
        metadataView: null,
      );
}
