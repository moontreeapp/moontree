import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/utilities/assets.dart';
import 'package:bloc/bloc.dart';
import 'package:client_front/infrastructure/repos/holdings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/application/common.dart';
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

  Future<void> setHoldingViews(
    Wallet wallet,
    ChainNet chainNet, {
    bool force = false,
  }) async {
    if (force ||
        state.holdingsViews.isEmpty ||
        state.ranWallet != wallet ||
        state.ranChainNet != chainNet) {
      set(
        holdingsViews: [],
        assetHoldings: [],
        isSubmitting: true,
      );
      final holdingViews = await HoldingsRepo(wallet: wallet).fetch();
      set(
        holdingsViews: holdingViews.toList(),
        assetHoldings: assetHoldings(holdingViews),
        ranWallet: wallet,
        ranChainNet: chainNet,
        isSubmitting: false,
      );
    }
  }

  Future<void> updateHoldingView(
    Wallet wallet,
    ChainNet chainNet, {
    required String symbol,
    required int satsConfirmed,
    required int satsUnconfirmed,
  }) async {
    bool found = false;
    List<BalanceView> holdingViews = [];
    for (final BalanceView view in state.holdingsViews) {
      if (view.chain == chainNet.chain &&
          view.symbol == symbol &&
          view.error == null) {
        holdingViews.add(BalanceView(
          chain: view.chain,
          symbol: view.symbol,
          satsConfirmed: satsConfirmed,
          satsUnconfirmed: satsUnconfirmed,
        ));
        found = true;
      } else {
        holdingViews.add(view);
      }
    }
    if (found == false) {
      await setHoldingViews(wallet, chainNet);
    } else {
      set(
        holdingsViews: holdingViews,
        assetHoldings: assetHoldings(holdingViews),
        ranWallet: wallet,
        ranChainNet: chainNet,
        isSubmitting: false,
      );
    }
  }

  void clearCache() => set(holdingsViews: <BalanceView>[]);

  BalanceView? holdingsViewFor(String symbol) =>
      state.holdingsViews.where((e) => e.symbol == symbol).firstOrNull;

// we want to group certain assets into one view so we arrange them into this:
}
