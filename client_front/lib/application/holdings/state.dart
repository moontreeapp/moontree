part of 'cubit.dart';

@immutable
class HoldingsViewState extends CubitState {
  final List<BalanceView> holdingsViews;
  final List<AssetHolding> assetHoldings;
  final Wallet? ranWallet;
  final ChainNet? ranChainNet;
  final bool isSubmitting;
  // for holdingsViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and

  const HoldingsViewState({
    required this.holdingsViews,
    required this.assetHoldings,
    required this.ranWallet,
    required this.ranChainNet,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingsViewSate( '
      'holdingsViews=$holdingsViews, '
      'assetHoldings=$assetHoldings, '
      'ranWallet=$ranWallet, '
      'ranChainNet=$ranChainNet, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        holdingsViews,
        assetHoldings,
        ranWallet,
        ranChainNet,
        isSubmitting,
      ];

  factory HoldingsViewState.initial() => HoldingsViewState(
      holdingsViews: [],
      assetHoldings: [],
      ranWallet: null,
      ranChainNet: null,
      isSubmitting: true);

  HoldingsViewState load({
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? ranWallet,
    ChainNet? ranChainNet,
    bool? isSubmitting,
  }) =>
      HoldingsViewState.load(
        state: this,
        holdingsViews: holdingsViews,
        assetHoldings: assetHoldings,
        ranWallet: ranWallet,
        ranChainNet: ranChainNet,
        isSubmitting: isSubmitting,
      );

  factory HoldingsViewState.load({
    required HoldingsViewState state,
    List<BalanceView>? holdingsViews,
    List<AssetHolding>? assetHoldings,
    Wallet? ranWallet,
    ChainNet? ranChainNet,
    bool? isSubmitting,
  }) =>
      HoldingsViewState(
        holdingsViews: holdingsViews ?? state.holdingsViews,
        assetHoldings: assetHoldings ?? state.assetHoldings,
        ranWallet: ranWallet ?? state.ranWallet,
        ranChainNet: ranChainNet ?? state.ranChainNet,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
