part of 'cubit.dart';

abstract class NavbarHeightCubitState extends Equatable {
  final double height;
  final NavbarHeight currentNavbarHeight;
  final NavbarHeight previousNavbarHeight;

  const NavbarHeightCubitState(
    this.height,
    this.previousNavbarHeight,
    this.currentNavbarHeight,
  );

  @override
  List<Object> get props => [height];
}

class NavbarHeightState extends NavbarHeightCubitState {
  const NavbarHeightState({
    required double height,
    required NavbarHeight previousNavbarHeight,
    required NavbarHeight currentNavbarHeight,
  }) : super(height, previousNavbarHeight, currentNavbarHeight);
}
