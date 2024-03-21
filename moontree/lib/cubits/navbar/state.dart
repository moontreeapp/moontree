part of 'cubit.dart';

class NavbarState with EquatableMixin {
  final NavbarSection section;
  final NavbarState? prior;

  const NavbarState({
    this.section = NavbarSection.none,
    this.prior,
  });

  @override
  List<Object?> get props => [
        section,
        prior,
      ];

  @override
  String toString() => 'NavbarState( '
      'sections=$section, '
      'prior=$prior, '
      ')';

  NavbarState get withoutPrior => NavbarState(
        section: section,
        prior: null,
      );
}
