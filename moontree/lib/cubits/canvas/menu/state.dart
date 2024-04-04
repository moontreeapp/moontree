part of 'cubit.dart';

class MenuState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool faded;
  final Widget? child;
  final Side? side;
  final bool isSubmitting;
  final MenuState? prior;

  const MenuState({
    this.active = false,
    this.faded = false,
    this.child = const SizedBox.shrink(),
    this.side = Side.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        faded,
        child,
        side,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  MenuState get withoutPrior => MenuState(
        active: active,
        faded: faded,
        child: child,
        side: side,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
