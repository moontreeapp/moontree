part of 'cubit.dart';

class NavbarState with EquatableMixin {
  final NavbarSection section;
  final bool hidden;
  final NavbarState? prior;

  const NavbarState({
    this.section = NavbarSection.none,
    this.hidden = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        section,
        hidden,
        prior,
      ];

  @override
  String toString() => 'NavbarState( '
      'section=$section, '
      'hidden=$hidden, '
      'prior=$prior, '
      ')';

  NavbarState get withoutPrior => NavbarState(
        section: section,
        hidden: hidden,
        prior: null,
      );
}
