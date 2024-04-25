import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/side.dart';

part 'state.dart';

class MenuCubit extends UpdatableCubit<MenuState> {
  MenuCubit() : super(const MenuState());
  @override
  String get key => 'menu';
  @override
  void reset() => emit(const MenuState());
  @override
  void setState(MenuState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void update({
    bool? active,
    bool? faded,
    Widget? child,
    Side? side,
    DifficultyMode? mode,
    SubMenu? sub,
    bool? isSubmitting,
    MenuState? prior,
  }) {
    emit(MenuState(
      active: active ?? state.active,
      faded: faded ?? state.faded,
      child: child ?? state.child,
      side: side ?? state.side,
      mode: mode ?? state.mode,
      sub: sub ?? state.sub,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  void toggleDifficulty() {
    if (state.mode == DifficultyMode.easy) {
      update(mode: DifficultyMode.hard);
    } else {
      update(mode: DifficultyMode.easy);
    }
  }
}
