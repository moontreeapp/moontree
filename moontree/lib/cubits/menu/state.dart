part of 'cubit.dart';

class MenuState with EquatableMixin {
  final bool active;
  final Widget? child;
  final Side? side;
  final bool isSubmitting;
  final MenuState? prior;

  const MenuState({
    this.active = false,
    this.child = const SizedBox.shrink(),
    this.side = Side.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        child,
        side,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  MenuState get withoutPrior => MenuState(
        active: active,
        child: child,
        side: side,
        isSubmitting: isSubmitting,
        prior: null,
      );

  bool get wasInactive => (prior?.active == null || !prior!.active);
  bool get wasActive => !wasInactive;
}
