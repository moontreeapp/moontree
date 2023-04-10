// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

enum SnackbarHeight {
  max,
  mid,
  hidden,
  same,
}

class SnackbarCubit extends Cubit<SnackbarCubitState> {
  SnackbarCubit()
      : super(
          SnackbarState(
              showSections: false,
              height: 0,
              previousSnackbarHeight: SnackbarHeight.hidden,
              currentSnackbarHeight: SnackbarHeight.hidden),
        );

  void update({
    bool? showSections,
    double? height,
    SnackbarHeight? previousSnackbarHeight,
    SnackbarHeight? currentSnackbarHeight,
  }) {
    emit(SnackbarState(
      showSections: showSections ?? state.showSections,
      height: height ?? state.height,
      previousSnackbarHeight:
          previousSnackbarHeight ?? state.previousSnackbarHeight,
      currentSnackbarHeight:
          currentSnackbarHeight ?? state.currentSnackbarHeight,
    ));
  }

  void showSections() => update(showSections: true);
  void hideSections() => update(showSections: false);

  void setHeightTo({required SnackbarHeight height}) {
    switch (height) {
      case SnackbarHeight.max:
        return max();
      case SnackbarHeight.mid:
        return mid();
      case SnackbarHeight.hidden:
        return hidden();
      case SnackbarHeight.same:
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
        previousSnackbarHeight: state.currentSnackbarHeight,
        currentSnackbarHeight: SnackbarHeight.max,
      );

  void mid() => update(
        height: services.screen.navbar.midHeight,
        previousSnackbarHeight: state.currentSnackbarHeight,
        currentSnackbarHeight: SnackbarHeight.mid,
      );

  void hidden() => update(
        height: 0,
        previousSnackbarHeight: state.currentSnackbarHeight,
        currentSnackbarHeight: SnackbarHeight.hidden,
      );

  void menuToggle() {
    switch (state.currentSnackbarHeight) {
      case SnackbarHeight.hidden:
        return max();
      default:
        return hidden();
    }
  }

  void openMenu() => hidden();
  void closeMenu() => max();
}
