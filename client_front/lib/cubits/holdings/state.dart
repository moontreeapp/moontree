part of 'cubit.dart';

@immutable
class HoldingsViewState extends CubitState {
  final List<BalanceView> holdingsViews;
  final List<AssetHolding> assetHoldings;
  final Wallet wallet;
  final bool isSubmitting;
  // for holdingsViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and

  const HoldingsViewState({
    required this.holdingsViews,
    required this.assetHoldings,
    required this.wallet,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingsViewSate( '
      'holdingsViews=$holdingsViews, '
      'assetHoldings=$assetHoldings, '
      'wallet=$wallet, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        holdingsViews,
        assetHoldings,
        wallet,
        isSubmitting,
      ];

  factory HoldingsViewState.initial() => HoldingsViewState(
      holdingsViews: [],
      assetHoldings: [],
      wallet: pros.wallets.currentWallet,
      isSubmitting: true);

  HoldingsViewState load({
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? wallet,
    bool? isSubmitting,
  }) =>
      HoldingsViewState.load(
        state: this,
        holdingsViews: holdingsViews,
        assetHoldings: assetHoldings,
        wallet: wallet,
        isSubmitting: isSubmitting,
      );

  factory HoldingsViewState.load({
    required HoldingsViewState state,
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? wallet,
    bool? isSubmitting,
  }) =>
      HoldingsViewState(
        holdingsViews: holdingsViews ?? state.holdingsViews,
        assetHoldings: assetHoldings ?? state.assetHoldings,
        wallet: wallet ?? state.wallet,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
