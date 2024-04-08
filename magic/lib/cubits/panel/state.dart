part of 'cubit.dart';

class PanelState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Widget Function(ScrollController)? child;
  final Side transition;
  final bool isSubmitting;
  final PanelState? prior;

  const PanelState({
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
  PanelState get withoutPrior => PanelState(
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
