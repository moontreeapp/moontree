// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

enum NavbarHeight {
  max,
  mid,
  hidden,
  same,
}

class NavbarHeightCubit extends Cubit<NavbarHeightCubitState> {
  NavbarHeightCubit()
      : super(
          NavbarHeightState(
              height: 0,
              previousNavbarHeight: NavbarHeight.hidden,
              currentNavbarHeight: NavbarHeight.hidden),
        );

  void setHeightTo({required NavbarHeight height}) {
    switch (height) {
      case NavbarHeight.max:
        return max();
      case NavbarHeight.mid:
        return mid();
      case NavbarHeight.hidden:
        return hidden();
      case NavbarHeight.same:
        return;
      default:
        return max();
    }
  }

  /// we're currently hiding the context buttons until they're ready so,
  /// max height is midd height for now.
  void max() => emit(NavbarHeightState(
        height: services.screen.navbar.midHeight,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.max,
      ));

  void mid() => emit(NavbarHeightState(
        height: services.screen.navbar.midHeight,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.mid,
      ));

  void hidden() => emit(NavbarHeightState(
        height: 0,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.hidden,
      ));
}
