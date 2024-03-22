part of 'cubit.dart';

class PaneState with EquatableMixin {
  final bool active;
  final double height;
  final Widget? child;
  final Widget Function(ScrollController)? scrollableChild;
  final Side transition;
  final bool isSubmitting;
  final PaneState? prior;

  const PaneState({
    this.active = false,
    this.height = 20,
    this.child,
    this.scrollableChild,
    this.transition = Side.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        height,
        child,
        scrollableChild,
        transition,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  PaneState get withoutPrior => PaneState(
        active: active,
        height: height,
        child: child,
        scrollableChild: scrollableChild,
        transition: transition,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
