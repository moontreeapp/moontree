import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/side.dart';

part 'state.dart';

class PanelCubit extends UpdatableCubit<PanelState> {
  PanelCubit() : super(const PanelState());
  @override
  String get key => 'panel';
  @override
  void reset() => emit(const PanelState());
  @override
  void setState(PanelState state) => emit(state);
  @override
  void refresh() => update(isSubmitting: true);
  @override
  void hide() => update(active: false);
  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void update({
    bool? active,
    Widget Function(ScrollController)? child,
    Side? transition,
    bool? isSubmitting,
  }) {
    emit(PanelState(
      active: active ?? state.active,
      child: child ?? state.child,
      transition: transition ?? state.transition,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }
}
