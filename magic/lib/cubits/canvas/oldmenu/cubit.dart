import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/side.dart';

part 'state.dart';

class OldMenuCubit extends UpdatableCubit<OldMenuState> {
  OldMenuCubit() : super(const OldMenuState());
  @override
  String get key => 'menu';
  @override
  void reset() => emit(const OldMenuState());
  @override
  void setState(OldMenuState state) => emit(state);
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
    bool? setting,
    bool? isSubmitting,
    OldMenuState? prior,
  }) {
    emit(OldMenuState(
      active: active ?? state.active,
      faded: faded ?? state.faded,
      child: child ?? state.child,
      side: side ?? state.side,
      mode: mode ?? state.mode,
      sub: sub ?? state.sub,
      setting: setting ?? state.setting,
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

  void toggleSetting() => update(setting: !state.setting);
  bool get isInEasyMode => state.mode == DifficultyMode.easy;
  bool get isInHardMode => state.mode == DifficultyMode.hard;
  bool get isInDevMode => state.mode == DifficultyMode.dev;
  bool get isInHardOrDevMode =>
      [DifficultyMode.hard, DifficultyMode.hard].contains(state.mode);
}
