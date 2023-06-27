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
      TransactionViewState(
        transactionView: transactionView ?? this.transactionView,
        ranHash: ranHash ?? this.ranHash,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
