part of 'cubit.dart';

class BalanceState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool faded;
  final double portfolioValue;
  final bool isSubmitting;
  final BalanceState? prior;

  const BalanceState({
    this.active = false,
    this.faded = false,
    this.portfolioValue = 0.0,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        faded,
        portfolioValue,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  BalanceState get withoutPrior => BalanceState(
        active: active,
        faded: faded,
        portfolioValue: portfolioValue,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;

  String get portfolioHead => portfolioValue.toString().split('.').first;
  String get portfolioTail {
    final cents = '.${portfolioValue.toString().split('.').last}';
    if (cents.length == 2) {
      return '${cents}0';
    }
    if (cents.length == 3) {
      return cents;
    }
    return cents.substring(0, 3);
  }
}
