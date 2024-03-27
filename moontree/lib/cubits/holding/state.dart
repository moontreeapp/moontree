part of 'cubit.dart';

class HoldingState with EquatableMixin {
  final bool active;
  final bool isSubmitting;
  final HoldingState? prior;

  const HoldingState({
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

  HoldingState get withoutPrior => HoldingState(
        active: active,
        isSubmitting: isSubmitting,
        prior: null,
      );

  bool get wasInactive => (prior?.active == null || !prior!.active);
  bool get wasActive => !wasInactive;
}
