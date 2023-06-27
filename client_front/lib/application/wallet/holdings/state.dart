part of 'cubit.dart';

@immutable
abstract class WalletHoldingsViewCubitState extends CubitState {
  final List<BalanceView> holdingsViews;
  final List<AssetHolding> assetHoldings;
  final Wallet? ranWallet;
  final ChainNet? ranChainNet;
  final bool showUSD;
  final bool showPath;
  final Map<ChainNet, List<Wallet>> startedDerive;
  final bool isSubmitting;
  // for holdingsViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and

  const WalletHoldingsViewCubitState({
    required this.holdingsViews,
    required this.assetHoldings,
    required this.ranWallet,
    required this.ranChainNet,
    required this.showUSD,
    required this.showPath,
    required this.startedDerive,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingsViewSate( '
      'holdingsViews=$holdingsViews, '
      'assetHoldings=$assetHoldings, '
      'ranWallet=$ranWallet, '
      'ranChainNet=$ranChainNet, '
      'showUSD=$showUSD, '
      'showPath=$showPath, '
      'startedDerive=$startedDerive, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        holdingsViews,
        assetHoldings,
        ranWallet,
        ranChainNet,
        showUSD,
        showPath,
        startedDerive,
        isSubmitting,
      ];
}

class WalletHoldingsViewState extends WalletHoldingsViewCubitState {
  const WalletHoldingsViewState({
    required super.holdingsViews,
    required super.assetHoldings,
    required super.ranWallet,
    required super.ranChainNet,
    required super.showUSD,
    required super.showPath,
    required super.startedDerive,
    required super.isSubmitting,
  });
}
