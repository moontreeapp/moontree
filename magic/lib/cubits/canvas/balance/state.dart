part of 'cubit.dart';

class BalanceState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Fiat portfolioValue;
  final bool isSubmitting;
  final BalanceState? prior;

  const BalanceState({
    this.active = false,
    this.portfolioValue = const Fiat.empty(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        portfolioValue,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  BalanceState get withoutPrior => BalanceState(
        active: active,
        portfolioValue: portfolioValue,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
