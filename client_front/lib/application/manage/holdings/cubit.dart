import 'package:client_front/application/manage/holdings/derive.dart';
import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/utilities/assets.dart';
import 'package:client_front/infrastructure/repos/holdings.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:client_front/application/common.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class ManageHoldingsViewCubit extends Cubit<ManageHoldingsViewState> {
  ManageHoldingsViewCubit()
      : super(ManageHoldingsViewState(
            holdingsViews: [],
            assetHoldings: [],
            ranWallet: null,
            ranChainNet: null,
            search: '',
            showUSD: false,
            showPath: false,
            showSearchBar: false,
            startedDerive: {},
            isSubmitting: true));

  Future<void> enter() async {
    emit(state);
  }

  Future<void> refresh() async {
    update(
      isSubmitting: true,
    );
  }

  void update({
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? ranWallet,
    ChainNet? ranChainNet,
    String? search,
    bool? showUSD,
    bool? showPath,
    bool? showSearchBar,
    Map<ChainNet, List<Wallet>>? startedDerive,
    bool? isSubmitting,
  }) {
    emit(ManageHoldingsViewState(
      holdingsViews: holdingsViews ?? state.holdingsViews,
      assetHoldings: assetHoldings ?? state.assetHoldings,
      ranWallet: ranWallet ?? state.ranWallet,
      ranChainNet: ranChainNet ?? state.ranChainNet,
      search: search ?? state.search,
      showUSD: showUSD ?? state.showUSD,
      showPath: showPath ?? state.showPath,
      showSearchBar: showSearchBar ?? state.showSearchBar,
      startedDerive: startedDerive ?? state.startedDerive,
      isSubmitting: isSubmitting ?? state.isSubmitting,
    ));
  }

  Future<void> setHoldingViews({
    Wallet? wallet,
    ChainNet? chainNet,
    bool force = false,
  }) async {
    /// filter down to holdings that are or have matching admin assets
    Iterable<BalanceView> filterToManageableAssets(
        Iterable<BalanceView> holdingViews) {
      // return the admins and assets we hold that correspond to them.
      //final Iterable<String> adminSymbols =
      //    holdingViews.where((e) => e.symbol.isAdmin).map((e) => e.symbol);
      //return holdingViews.where((e) =>
      //    e.symbol.isAdmin ||
      //    adminSymbols.contains(Symbol(e.symbol).toAdminSymbol));

      // actually, we just need the admin symbols I think
      //return holdingViews.where((e) => e.symbol.isAdmin);

      // actually, what would be best is if we went and got the symbols which
      // this admin symbol control. then just display those.
      return holdingViews.where((e) => e.symbol.isAdmin).map((e) => BalanceView(
          satsConfirmed: 0,
          satsUnconfirmed: 0,
          symbol: Symbol(e.symbol).toMainSymbol!,
          chain: e.chain));
    }

    wallet ??= Current.wallet;
    chainNet ??= Current.chainNet;
    if (force ||
        state.holdingsViews.isEmpty ||
        state.ranWallet != wallet ||
        state.ranChainNet != chainNet) {
      update(
        holdingsViews: [],
        assetHoldings: [],
        isSubmitting: true,
      );
      Iterable<BalanceView> holdingViews =
          filterToManageableAssets(await HoldingsRepo(wallet: wallet).fetch());
      Map<ChainNet, List<Wallet>> startedDerive = state.startedDerive;
      if (wallet is LeaderWallet &&
          (!(state.startedDerive.get(chainNet, [])?.contains(wallet) ??
              false))) {
        /// spin off a slow derivation process in the background.
        /// had lots of trouble with this. turns out the LeaderWallet being
        /// passed to the isolate is the issue. I think it's Hive, and frankly,
        /// I don't even know if an isolate would have access to the proclaim
        /// and disk functionality we have setup. so. instead we derive with a
        /// future, but very slowly, so it doesn't noticably interfere with the
        /// front end animations. by the way, I anticipate we'll someday stop
        /// using hive, because we might covert this to a web wallet too, idk.
        /// we might have more luck making use of compute in that case. maybe.
        //compute(preDerive, [wallet, chainNet]);
        preDeriveInBackground(wallet, chainNet);

        startedDerive[chainNet] =
            (state.startedDerive[chainNet] ?? []) + [wallet];
      }
      update(
        holdingsViews: holdingViews.toList(),
        assetHoldings: assetHoldings(holdingViews, chainNet),
        ranWallet: wallet,
        ranChainNet: chainNet,
        startedDerive: startedDerive,
        isSubmitting: false,
      );
    }
  }

  /* /// unused, presumably for pagination
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
      await setHoldingViews(wallet: wallet, chainNet: chainNet);
    } else {
      update(
        holdingsViews: holdingViews,
        assetHoldings: assetHoldings(holdingViews),
        ranWallet: wallet,
        ranChainNet: chainNet,
        isSubmitting: false,
      );
    }
  }
  */

  void clearCache() => update(holdingsViews: <BalanceView>[]);

  BalanceView? holdingsViewFor(String symbol) =>
      state.holdingsViews.where((e) => e.symbol == symbol).firstOrNull;

  bool get walletEmpty => state.holdingsViews.map((e) => e.sats).sum == 0;
  bool get walletEmptyCoin =>
      state.holdingsViews.where((e) => e.isCoin).map((e) => e.sats).sum == 0;

// we want to group certain assets into one view so we arrange them into this:
}
