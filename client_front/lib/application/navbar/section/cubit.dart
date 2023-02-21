// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class NavbarSectionCubit extends Cubit<NavbarSectionCubitState> {
  NavbarSectionCubit() : super(const NavbarSectionState(show: false));

  void show() => emit(const NavbarSectionState(show: true));

  void hide() => emit(const NavbarSectionState(show: false));
}
