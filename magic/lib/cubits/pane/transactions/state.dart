part of 'cubit.dart';

@immutable
class TransactionsState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Holding asset;
  final List<TransactionDisplay> transactions;
  final Widget child;
  final bool isSubmitting;
  final TransactionsState? prior;

  const TransactionsState({
    this.active = false,
    this.asset = const Holding.empty(),
    this.transactions = const [],
    this.child = const SizedBox.shrink(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        active,
        asset,
        transactions,
        child,
        isSubmitting,
        prior,
      ];

  @override
  TransactionsState get withoutPrior => TransactionsState(
        active: active,
        asset: asset,
        transactions: transactions,
        child: child,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
