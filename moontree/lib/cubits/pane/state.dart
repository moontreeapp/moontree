part of 'cubit.dart';

class PaneState with EquatableMixin {
  final bool active;
  // pixel
  final double height;
  // percentage
  final double initial;
  final double min;
  final double max;
  final Widget? child;
  final DraggableScrollableController controller;
  final Widget Function(ScrollController)? scrollableChild;
  final Side transition;
  final bool isSubmitting;
  final PaneState? prior;

  const PaneState({
    this.active = false,
    this.height = 20,
    this.initial = .618,
    this.min = .0,
    this.max = 1,
    this.child,
    required this.controller,
    this.scrollableChild,
    this.transition = Side.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        height,
        initial,
        min,
        max,
        controller,
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
        initial: initial,
        min: min,
        max: max,
        controller: controller,
        child: child,
        scrollableChild: scrollableChild,
        transition: transition,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
