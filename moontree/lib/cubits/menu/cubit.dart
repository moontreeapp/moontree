import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';
import 'package:moontree/domain/concepts/side.dart';

part 'state.dart';

class MenuCubit extends Cubit<MenuState> with UpdateHideMixin<MenuState> {
  MenuCubit() : super(const MenuState());
  double height = 0;
  @override
  String get key => 'menu';
  @override
  void reset() => emit(const MenuState());
  @override
  void setState(MenuState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    Widget? child,
    Side? side,
    bool? isSubmitting,
    MenuState? prior,
  }) {
    emit(MenuState(
      active: active ?? state.active,
      child: child ?? state.child,
      side: side ?? state.side,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
