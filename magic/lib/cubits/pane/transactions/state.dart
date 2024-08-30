part of 'cubit.dart';

@immutable
class TransactionsState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Holding asset;
  final List<TransactionDisplay> mempool;
  final List<TransactionDisplay> transactions;
  final Widget child;
  final bool clearing;
  final bool isSubmitting;
  final TransactionsState? prior;

  const TransactionsState({
    this.active = false,
    this.asset = const Holding.empty(),
    this.mempool = const [],
    this.transactions = const [],
    this.child = const SizedBox.shrink(),
    this.clearing = false,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        active,
        asset,
        mempool,
        transactions,
        child,
        clearing,
        isSubmitting,
        prior,
      ];

  @override
  TransactionsState get withoutPrior => TransactionsState(
        active: active,
        asset: asset,
        mempool: mempool,
        transactions: transactions,
        child: child,
        clearing: clearing,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
