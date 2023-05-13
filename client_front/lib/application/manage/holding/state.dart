part of 'cubit.dart';

@immutable
class ManageHoldingViewState extends CubitState {
  final AssetMetadata? metadataView;
  final Wallet? wallet;
  final Security security;
  final bool isSubmitting;
  // allows us to remember what the wallet and security was last time we called
  // for transactionViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and
  // security immediately, showing on coinspec while we wait for the views.
  final Wallet? ranWallet;
  final Security? ranSecurity;

  const ManageHoldingViewState({
    required this.metadataView,
    required this.wallet,
    required this.security,
    required this.isSubmitting,
    required this.ranWallet,
    required this.ranSecurity,
  });

  ManageHoldingViewState reset() {
    return this;
  }

  @override
  String toString() => 'TransactionsView( '
      'metadataView=$metadataView, wallet=$wallet, security=$security, '
      'ranWallet=$ranWallet, ranSecurity=$ranSecurity, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        metadataView,
        wallet,
        security,
        ranWallet,
        ranSecurity,
        isSubmitting,
      ];

  factory ManageHoldingViewState.initial() => ManageHoldingViewState(
      metadataView: null,
      wallet:
          pros.wallets.records.length == 0 ? null : pros.wallets.currentWallet,
      security: pros.securities.currentCoin,
      ranWallet: null,
      ranSecurity: null,
      isSubmitting: true);

  ManageHoldingViewState load({
    List<TransactionView>? transactionViews,
    List<TransactionView>? mempoolViews,
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    bool? end,
    Wallet? ranWallet,
    Security? ranSecurity,
    int? ranHeight,
    bool? isSubmitting,
  }) =>
      ManageHoldingViewState(
        metadataView: metadataView ?? this.metadataView,
        wallet: wallet ?? this.wallet,
        security: security ?? this.security,
        ranWallet: ranWallet ?? this.ranWallet,
        ranSecurity: ranSecurity ?? this.ranSecurity,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
