part of 'cubit.dart';

enum DifficultyMode {
  easy,
  hard,
  dev;

  String get name {
    switch (this) {
      case DifficultyMode.easy:
        return 'Easy';
      case DifficultyMode.hard:
        return 'Advanced';
      case DifficultyMode.dev:
        return 'Dev';
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyMode.easy:
        return Icons.sledding_rounded;
      case DifficultyMode.hard:
        return Icons.snowboarding_rounded;
      case DifficultyMode.dev:
        return Icons.scuba_diving_rounded;
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

class OldMenuState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool faded;
  final Widget? child;
  final Side? side;
  final DifficultyMode mode;
  final SubMenu sub;
  final bool setting;
  final bool isSubmitting;
  final OldMenuState? prior;

  const OldMenuState({
    this.active = false,
    this.faded = false,
    this.child = const SizedBox.shrink(),
    this.side = Side.none,
    this.mode = DifficultyMode.easy,
    this.sub = SubMenu.none,
    this.setting = false,
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
        setting,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  OldMenuState get withoutPrior => OldMenuState(
        active: active,
        faded: faded,
        child: child,
        side: side,
        mode: mode,
        sub: sub,
        setting: setting,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
