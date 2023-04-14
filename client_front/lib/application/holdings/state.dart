part of 'cubit.dart';

@immutable
abstract class HoldingsViewCubitState extends CubitState {
  final List<BalanceView> holdingsViews;
  final List<AssetHolding> assetHoldings;
  final Wallet? ranWallet;
  final ChainNet? ranChainNet;
  final String search;
  final bool showUSD;
  final bool showPath;
  final bool showSearchBar;
  final Map<ChainNet, List<Wallet>> startedDerive;
  final bool isSubmitting;
  // for holdingsViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and

  const HoldingsViewCubitState({
    required this.holdingsViews,
    required this.assetHoldings,
    required this.ranWallet,
    required this.ranChainNet,
    required this.search,
    required this.showUSD,
    required this.showPath,
    required this.showSearchBar,
    required this.startedDerive,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingsViewSate( '
      'holdingsViews=$holdingsViews, '
      'assetHoldings=$assetHoldings, '
      'ranWallet=$ranWallet, '
      'ranChainNet=$ranChainNet, '
      'search=$search, '
      'showUSD=$showUSD, '
      'showPath=$showPath, '
      'showSearchBar=$showSearchBar, '
      'showSearchBar=$startedDerive, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        holdingsViews,
        assetHoldings,
        ranWallet,
        ranChainNet,
        search,
        showUSD,
        showPath,
        showSearchBar,
        startedDerive,
        isSubmitting,
      ];
}

class HoldingsViewState extends HoldingsViewCubitState {
  const HoldingsViewState({
    required super.holdingsViews,
    required super.assetHoldings,
    required super.ranWallet,
    required super.ranChainNet,
    required super.search,
    required super.showUSD,
    required super.showPath,
    required super.showSearchBar,
    required super.startedDerive,
    required super.isSubmitting,
  });
}
