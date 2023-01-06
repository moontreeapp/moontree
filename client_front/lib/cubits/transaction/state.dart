part of 'cubit.dart';

@immutable
class TransactionViewState extends CubitState {
  final TransactionDetailsView? transactionView;
  final bool isSubmitting;

  const TransactionViewState({
    this.transactionView,
    required this.isSubmitting,
  });

  @override
  String toString() => 'TransactionView( '
      'transactionView=$transactionView, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        transactionView,
        isSubmitting,
      ];

  factory TransactionViewState.initial() =>
      TransactionViewState(transactionView: null, isSubmitting: true);

  TransactionViewState load({
    TransactionDetailsView? transactionView,
    bool? isSubmitting,
  }) =>
      TransactionViewState.load(
        state: this,
        transactionView: transactionView,
        isSubmitting: isSubmitting,
      );

  factory TransactionViewState.load({
    required TransactionViewState state,
    TransactionDetailsView? transactionView,
    bool? isSubmitting,
  }) =>
      TransactionViewState(
        transactionView: transactionView ?? state.transactionView,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
