part of 'cubit.dart';

@immutable
class TransactionsViewState extends CubitState {
  final List<TransactionView> transactionViews;
  final bool isSubmitting;

  /// include these in state and repull if changed?
  //Wallet? wallet,
  //String? symbol,
  //Security? security,

  const TransactionsViewState({
    required this.transactionViews,
    required this.isSubmitting,
  });

  @override
  String toString() => 'TransactionsView(transactionViews=$transactionViews, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object> get props => <Object>[
        transactionViews,
        isSubmitting,
      ];

  factory TransactionsViewState.initial() =>
      TransactionsViewState(transactionViews: [], isSubmitting: true);

  TransactionsViewState load({
    List<TransactionView>? transactionViews,
    bool? isSubmitting,
  }) =>
      TransactionsViewState.load(
        form: this,
        transactionViews: transactionViews,
        isSubmitting: isSubmitting,
      );

  factory TransactionsViewState.load({
    required TransactionsViewState form,
    List<TransactionView>? transactionViews,
    bool? isSubmitting,
  }) =>
      TransactionsViewState(
        transactionViews: transactionViews ?? form.transactionViews,
        isSubmitting: isSubmitting ?? form.isSubmitting,
      );
}
