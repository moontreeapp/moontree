// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/sections.dart';
import 'package:moontree/services/services.dart' show screen;

part 'state.dart';

enum NavbarHeight {
  full,
  max,
  nav,
  mid,
  min,
  hidden,
  none,
  same,
}

enum ExtendedNavbarItem { say, search, gallery, none }

class NavbarCubit extends Cubit<NavbarState> with UpdateMixin<NavbarState> {
  NavbarCubit() : super(NavbarState(height: screen.navbar.sectionsHeight));
  @override
  void reset() => emit(NavbarState(height: screen.navbar.sectionsHeight));
  @override
  void setState(NavbarState state) => emit(state);

  @override
  void update({
    NavbarSection? section,
    bool? navOnly,
    ExtendedNavbarItem? extendedSelected,
    double? height,
    NavbarHeight? navbarHeight,
    NavbarHeight? currentHeight,
    bool? edit,
    bool resetScroll = false,
  }) {
    emit(NavbarState(
      section: section ?? state.section,
      navOnly: navOnly ?? state.navOnly,
      height: height ?? state.height,
      extendedSelected: extendedSelected ?? state.extendedSelected,
      navbarHeight: navbarHeight ?? state.navbarHeight,
      currentHeight: currentHeight ?? state.currentHeight,
      edit: edit ?? state.edit,
      prior: state.withoutPrior,
    ));
  }

  void setHeightTo({required NavbarHeight height}) {
    switch (height) {
      case NavbarHeight.full:
        return full();
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

  void full({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool? edit,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected: extendedSelected ?? state.extendedSelected,
        height: screen.navbar.fullHeight,
        navbarHeight: NavbarHeight.full,
        edit: edit ?? state.edit,
      );

  /// we're currently hiding the context buttons until they're ready so,
  /// max height is midd height for now.
  void max({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool? edit,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected: extendedSelected ?? state.extendedSelected,
        height: screen.navbar.maxHeight,
        navbarHeight: NavbarHeight.max,
        edit: edit ?? state.edit,
      );

  void nav({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool? edit,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected:
            extendedSelected /*?? ExtendedNavbarItem.none // no */,
        height: screen.navbar.navHeight,
        navbarHeight: NavbarHeight.nav,
        edit: edit ?? state.edit,
      );

  void mid({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool? edit,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected:
            extendedSelected /*?? ExtendedNavbarItem.none // no */,
        height: screen.navbar.midHeight,
        navbarHeight: NavbarHeight.mid,
        edit: edit ?? state.edit,
      );

  void min({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool? edit,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected: extendedSelected,
        height: screen.navbar.minHeight,
        navbarHeight: NavbarHeight.min,
        edit: edit ?? state.edit,
      );

  void hidden({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool resetScroll = false,
  }) =>
      update(
        navOnly: false,
        section: section ?? state.section,
        extendedSelected: extendedSelected,
        height: 0,
        navbarHeight: NavbarHeight.hidden,
      );

  void navOnly({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool resetScroll = false,
  }) =>
      update(
        navOnly: true,
        section: section ?? state.section,
        extendedSelected: extendedSelected,
        height: 0,
        navbarHeight: NavbarHeight.hidden,
      );

  void none({
    NavbarSection? section,
    ExtendedNavbarItem? extendedSelected,
    bool resetScroll = false,
  }) =>
      update(
        navOnly: true,
        section: section ?? state.section,
        extendedSelected: extendedSelected,
        height: 0,
        navbarHeight: NavbarHeight.none,
      );

  bool get atWallet => state.section == NavbarSection.wallet;
  bool get atSend => state.section == NavbarSection.send;
  bool get atRecieve => state.section == NavbarSection.recieve;
  bool get atManage => state.section == NavbarSection.manage;
}
