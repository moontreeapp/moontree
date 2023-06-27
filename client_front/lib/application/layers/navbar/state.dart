part of 'cubit.dart';

abstract class NavbarCubitState extends Equatable {
  final bool showSections;
  final double height;
  final NavbarHeight currentNavbarHeight;
  final NavbarHeight previousNavbarHeight;

  const NavbarCubitState(
    this.showSections,
    this.height,
    this.previousNavbarHeight,
    this.currentNavbarHeight,
  );

  @override
  List<Object> get props => [
        showSections,
        height,
        previousNavbarHeight,
        currentNavbarHeight,
      ];
}

class NavbarState extends NavbarCubitState {
  const NavbarState({
    required bool showSections,
    required double height,
    required NavbarHeight previousNavbarHeight,
    required NavbarHeight currentNavbarHeight,
  }) : super(
          showSections,
          height,
          previousNavbarHeight,
          currentNavbarHeight,
        );
}
