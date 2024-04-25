part of 'cubit.dart';

enum DifficultyMode {
  easy,
  hard;

  String get name {
    switch (this) {
      case DifficultyMode.easy:
        return 'Easy';
      case DifficultyMode.hard:
        return 'Hard';
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyMode.easy:
        return Icons.sledding_rounded;
      case DifficultyMode.hard:
        return Icons.snowboarding_rounded;
    }
  }
}

enum SubMenu {
  none,
  help,
  mode,
  settings,
  about;
}

class MenuState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool faded;
  final Widget? child;
  final Side? side;
  final DifficultyMode mode;
  final SubMenu sub;
  final bool isSubmitting;
  final MenuState? prior;

  const MenuState({
    this.active = false,
    this.faded = false,
    this.child = const SizedBox.shrink(),
    this.side = Side.none,
    this.mode = DifficultyMode.easy,
    this.sub = SubMenu.none,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        faded,
        child,
        side,
        mode,
        sub,
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
        mode: mode,
        sub: sub,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
