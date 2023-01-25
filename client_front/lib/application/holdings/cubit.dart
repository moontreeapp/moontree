import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/utilities/assets.dart';
import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_front/infrastructure/services/client/asset_metadata.dart';
import 'package:flutter/material.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/infrastructure/services/client/holdings.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:client_back/client_back.dart';
import 'package:client_front/application/parents.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class HoldingsViewCubit extends Cubit<HoldingsViewState> with SetCubitMixin {
  HoldingsViewCubit() : super(HoldingsViewState.initial());

  @override
  Future<void> reset() async => emit(HoldingsViewState.initial());

  @override
  HoldingsViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    //emit(submitting());
    emit(state);
  }

  @override
  void set({
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? ranWallet,
    ChainNet? ranChainNet,
    bool? isSubmitting,
  }) {
    //emit(submitting());
    emit(state.load(
      holdingsViews: holdingsViews,
      assetHoldings: assetHoldings,
      ranWallet: ranWallet,
      ranChainNet: ranChainNet,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> setHoldingViews(Wallet wallet, ChainNet chainNet,
      {bool force = false}) async {
    if (force ||
        state.holdingsViews.isEmpty ||
        state.ranWallet != wallet ||
        state.ranChainNet != chainNet) {
      List<BalanceView> holdingViews = await discoverHoldingBalances(
        wallet: wallet,
      );
      set(
        holdingsViews: [],
        assetHoldings: [],
        isSubmitting: true,
      );
      set(
        holdingsViews: holdingViews,
        assetHoldings: assetHoldings(holdingViews),
        ranWallet: wallet,
        ranChainNet: chainNet,
        isSubmitting: false,
      );
    }
  }

  void clearCache() => set(
        holdingsViews: <BalanceView>[],
      );

// we want to group certain assets into one view so we arrange them into this:
}