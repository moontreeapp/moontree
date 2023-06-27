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

class NavbarCubit extends Cubit<NavbarCubitState> {
  NavbarCubit()
      : super(
          NavbarState(
              showSections: true,
              height: 0,
              previousNavbarHeight: NavbarHeight.hidden,
              currentNavbarHeight: NavbarHeight.hidden),
        );

  void update({
    bool? showSections,
    double? height,
    NavbarHeight? previousNavbarHeight,
    NavbarHeight? currentNavbarHeight,
  }) {
    emit(NavbarState(
      showSections: showSections ?? state.showSections,
      height: height ?? state.height,
      previousNavbarHeight: previousNavbarHeight ?? state.previousNavbarHeight,
      currentNavbarHeight: currentNavbarHeight ?? state.currentNavbarHeight,
    ));
  }

  void showSections() => update(showSections: true);
  void hideSections() => update(showSections: false);

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
  void max() => update(
        height: state.showSections
            ? services.screen.navbar.maxHeight
            : services.screen.navbar.midHeight,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.max,
      );

  void mid() => update(
        height: services.screen.navbar.midHeight,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.mid,
      );

  void hidden() => update(
        height: 0,
        previousNavbarHeight: state.currentNavbarHeight,
        currentNavbarHeight: NavbarHeight.hidden,
      );

  void menuToggle() {
    switch (state.currentNavbarHeight) {
      case NavbarHeight.hidden:
        return max();
      default:
        return hidden();
    }
  }

  void openMenu() => hidden();
  void closeMenu() => max();
}
