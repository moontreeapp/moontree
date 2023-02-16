// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

enum NavbarHeight {
  max,
  mid,
  hidden,
}

class NavbarHeightCubit extends Cubit<NavbarHeightCubitState> {
  NavbarHeightCubit()
      : super(
          NavbarHeightState(
              height: services.screen.navbar.maxHeight,
              previousNavbarHeight: NavbarHeight.max,
              currentNavbarHeight: NavbarHeight.max),
        );

  void setHeightTo({required NavbarHeight height}) {
    switch (height) {
      case NavbarHeight.max:
        return max();
      case NavbarHeight.mid:
        return mid();
      case NavbarHeight.hidden:
        return hidden();
      default:
        return max();
    }
  }

  void max() => emit(NavbarHeightState(
        height: services.screen.navbar.maxHeight,
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
