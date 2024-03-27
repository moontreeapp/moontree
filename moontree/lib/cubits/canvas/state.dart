part of 'cubit.dart';

class CanvasState with EquatableMixin {
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

  CanvasState get withoutPrior => CanvasState(
        active: active,
        isSubmitting: isSubmitting,
        prior: null,
      );

  bool get wasInactive => (prior?.active == null || !prior!.active);
  bool get wasActive => !wasInactive;
}
