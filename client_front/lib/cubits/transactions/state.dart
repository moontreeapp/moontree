part of 'cubit.dart';

@immutable
class TransactionsViewState extends CubitState {
  final List<TransactionView> transactionViews;
  final AssetMetadata? metadataView;
  final Wallet wallet;
  final Security security;
  final BehaviorSubject<double> scrollObserver;
  final BehaviorSubject<String> currentTab;
  final bool isSubmitting;
  // allows us to remember what the wallet and security was last time we called
  // for transactionViews so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and
  // security immediately, showing on coinspec while we wait for the views.
  final Wallet? ranWallet;
  final Security? ranSecurity;

  const TransactionsViewState({
    required this.transactionViews,
    required this.metadataView,
    required this.scrollObserver,
    required this.currentTab,
    required this.wallet,
    required this.security,
    required this.isSubmitting,
    required this.ranWallet,
    required this.ranSecurity,
  });

  TransactionsViewState reset() {
    scrollObserver.close();
    currentTab.close();
    return this;
  }

  @override
  String toString() => 'TransactionsView( '
      'transactionViews=$transactionViews, metadataView=$metadataView, '
      'wallet=$wallet, security=$security, ranWallet=$ranWallet, '
      'ranSecurity=$ranSecurity, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        transactionViews,
        metadataView,
        wallet,
        security,
        ranWallet,
        ranSecurity,
        isSubmitting,
      ];

  factory TransactionsViewState.initial() => TransactionsViewState(
      transactionViews: [],
      metadataView: null,
      scrollObserver: BehaviorSubject<double>.seeded(.7),
      currentTab: BehaviorSubject<String>.seeded('HISTORY'),
      wallet: pros.wallets.currentWallet,
      security: pros.securities.currentCoin,
      ranWallet: null,
      ranSecurity: null,
      isSubmitting: true);

  TransactionsViewState load({
    List<TransactionView>? transactionViews,
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    Wallet? ranWallet,
    Security? ranSecurity,
    bool? isSubmitting,
  }) =>
      TransactionsViewState.load(
        state: this,
        transactionViews: transactionViews,
        metadataView: metadataView,
        wallet: wallet,
        security: security,
        ranWallet: ranWallet,
        ranSecurity: ranSecurity,
        isSubmitting: isSubmitting,
      );

  factory TransactionsViewState.load({
    required TransactionsViewState state,
    List<TransactionView>? transactionViews,
    AssetMetadata? metadataView,
    Wallet? wallet,
    Security? security,
    Wallet? ranWallet,
    Security? ranSecurity,
    bool? isSubmitting,
  }) =>
      TransactionsViewState(
        transactionViews: transactionViews ?? state.transactionViews,
        metadataView: metadataView ?? state.metadataView,
        wallet: wallet ?? state.wallet,
        security: security ?? state.security,
        ranWallet: ranWallet ?? state.ranWallet,
        ranSecurity: ranSecurity ?? state.ranSecurity,
        isSubmitting: isSubmitting ?? state.isSubmitting,
        scrollObserver: state.scrollObserver,
        currentTab: state.currentTab,
      );
}
