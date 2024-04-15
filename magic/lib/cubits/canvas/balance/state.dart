part of 'cubit.dart';

class BalanceState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool initialized;
  final Fiat portfolioValue;
  final bool isSubmitting;
  final BalanceState? prior;

  const BalanceState({
    this.active = false,
    this.initialized = false,
    this.portfolioValue = const Fiat.empty(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        initialized,
        portfolioValue,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  BalanceState get withoutPrior => BalanceState(
        active: active,
        initialized: initialized,
        portfolioValue: portfolioValue,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
