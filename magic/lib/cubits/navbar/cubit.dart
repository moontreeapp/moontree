// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/sections.dart';

part 'state.dart';

class NavbarCubit extends Cubit<NavbarState> with UpdateMixin<NavbarState> {
  NavbarCubit() : super(const NavbarState());
  @override
  String get key => 'navbar';
  @override
  void reset() => emit(const NavbarState());
  @override
  void setState(NavbarState state) => emit(state);
  @override
  void refresh() {}

  @override
  void update({
    bool? active,
    NavbarSection? section,
    bool? dropped,
  }) {
    emit(NavbarState(
      active: active ?? state.active,
      section: section ?? state.section,
      prior: state.withoutPrior,
    ));
  }

  void activate() => update(active: true);
  void deactivate() => update(active: false);
  bool get isActive => state.active;
  bool get wasActive => state.wasActive;
  bool get atWallet => state.section == NavbarSection.wallet;
  bool get atSwap => state.section == NavbarSection.swap;
  bool get atMint => state.section == NavbarSection.mint;
}
