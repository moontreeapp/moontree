part of 'cubit.dart';

class NavbarState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final NavbarSection section;
  final NavbarState? prior;

  const NavbarState({
    this.active = true,
    this.section = NavbarSection.none,
    this.prior,
  });

  @override
  List<Object?> get props => [
        active,
        section,
        prior,
      ];

  @override
  String toString() => 'NavbarState( '
      'active=$active, '
      'section=$section, '
      'prior=$prior, '
      ')';

  @override
  NavbarState get withoutPrior => NavbarState(
        active: active,
        section: section,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
