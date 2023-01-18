part of 'cubit.dart';

@immutable
class TransactionViewState extends CubitState {
  final TransactionDetailsView? transactionView;
  final ByteData? ranHash;
  final bool isSubmitting;

  const TransactionViewState({
    this.transactionView,
    this.ranHash,
    required this.isSubmitting,
  });

  @override
  String toString() => 'TransactionView( '
      'transactionView=$transactionView, ranHash=$ranHash '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        transactionView,
        ranHash,
        isSubmitting,
      ];

  factory TransactionViewState.initial() => TransactionViewState(
        transactionView: null,
        ranHash: null,
        isSubmitting: false,
      );

  TransactionViewState load({
    TransactionDetailsView? transactionView,
    ByteData? ranHash,
    bool? isSubmitting,
  }) =>
      TransactionViewState.load(
        state: this,
        transactionView: transactionView,
        ranHash: ranHash,
        isSubmitting: isSubmitting,
      );

  factory TransactionViewState.load({
    required TransactionViewState state,
    TransactionDetailsView? transactionView,
    ByteData? ranHash,
    bool? isSubmitting,
  }) =>
      TransactionViewState(
        transactionView: transactionView ?? state.transactionView,
        ranHash: ranHash ?? state.ranHash,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
