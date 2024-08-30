part of 'cubit.dart';

@immutable
class WalletState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final List<Holding> holdings;
  final List<Chips> chips;
  final Widget child;
  final bool isSubmitting;
  final WalletState? prior;

  const WalletState({
    this.active = false,
    this.holdings = const [],
    this.chips = const [Chips.all],
    this.child = const SizedBox.shrink(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        active,
        holdings,
        chips,
        child,
        isSubmitting,
        prior,
      ];

  @override
  WalletState get withoutPrior => WalletState(
        active: active,
        holdings: holdings,
        chips: chips,
        child: child,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
