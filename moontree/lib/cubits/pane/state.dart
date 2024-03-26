part of 'cubit.dart';

class PaneState with EquatableMixin {
  final bool active;
  final bool dispose;
  // pixel
  final double height;
  // percentage
  final double initial;
  final double min;
  final double max;
  final ScrollController? scroller;
  final DraggableScrollableController controller;
  final bool isSubmitting;
  final PaneState? prior;

  const PaneState({
    this.active = false,
    this.dispose = false,
    this.height = 20,
    this.initial = .618,
    this.min = .0,
    this.max = 1,
    this.scroller,
    required this.controller,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        dispose,
        height,
        initial,
        min,
        max,
        scroller,
        controller,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  PaneState get withoutPrior => PaneState(
        active: active,
        dispose: dispose,
        height: height,
        initial: initial,
        min: min,
        max: max,
        scroller: scroller,
        controller: controller,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
