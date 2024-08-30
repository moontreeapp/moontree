part of 'cubit.dart';

class WelcomeState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Widget? child;
  final Side transition;
  final bool isSubmitting;
  final WelcomeState? prior;

  const WelcomeState({
    this.active = false,
    this.child,
    this.transition = Side.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        child,
        transition,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  WelcomeState get withoutPrior => WelcomeState(
        active: active,
        child: child,
        transition: transition,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
