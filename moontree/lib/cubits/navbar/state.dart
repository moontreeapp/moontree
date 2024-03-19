part of 'cubit.dart';

class NavbarState with EquatableMixin {
  final NavbarSection section;
  final bool navOnly;
  final double height;
  final ExtendedNavbarItem extendedSelected;
  final NavbarHeight navbarHeight;
  final NavbarHeight currentHeight;
  final bool edit;
  final NavbarState? prior;

  const NavbarState({
    this.section = NavbarSection.wallet,
    this.navOnly = false,
    this.extendedSelected = ExtendedNavbarItem.none,
    this.height = 0,
    this.navbarHeight = NavbarHeight.hidden,
    this.currentHeight = NavbarHeight.hidden,
    this.edit = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        section,
        navOnly,
        height,
        extendedSelected,
        navbarHeight,
        currentHeight,
        edit,
        prior,
      ];

  @override
  String toString() => 'NavbarState( '
      'sections=$section, '
      'navOnly=$navOnly, '
      'height=$height, '
      'extendedSelected=$extendedSelected, '
      'navbarHeight=$navbarHeight, '
      'currentHeight=$currentHeight, '
      'edit=$edit, '
      'prior=$prior, '
      ')';

  NavbarState get withoutPrior => NavbarState(
        section: section,
        navOnly: navOnly,
        height: height,
        extendedSelected: extendedSelected,
        navbarHeight: navbarHeight,
        currentHeight: currentHeight,
        edit: edit,
        prior: null,
      );
}
