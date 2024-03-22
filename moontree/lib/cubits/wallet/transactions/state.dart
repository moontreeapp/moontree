part of 'cubit.dart';

class TransactionsLayerState with EquatableMixin {
  final bool active;

  final bool submitting;
  final TransactionsLayerState? prior;

  const TransactionsLayerState({
    this.active = true,
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        active,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  TransactionsLayerState get withoutPrior => TransactionsLayerState(
        active: active,
        submitting: submitting,
        prior: null,
      );
}
