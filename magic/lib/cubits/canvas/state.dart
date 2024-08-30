part of 'cubit.dart';

class CanvasState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool isSubmitting;
  final CanvasState? prior;

  const CanvasState({
    this.active = false,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  CanvasState get withoutPrior => CanvasState(
        active: active,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
