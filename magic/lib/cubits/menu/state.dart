part of 'cubit.dart';

class MenuState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool isSubmitting;
  final MenuState? prior;

  const MenuState({
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
  MenuState get withoutPrior => MenuState(
        active: active,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
