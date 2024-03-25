import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/side.dart';

part 'state.dart';

class PaneCubit extends Cubit<PaneState> with UpdateSectionMixin<PaneState> {
  PaneCubit() : super(const PaneState());
  @override
  String get key => 'pane';
  @override
  void reset() => emit(const PaneState());
  @override
  void setState(PaneState state) => emit(state);
  void refresh() => update(isSubmitting: true);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    double? height,
    Widget Function(ScrollController)? scrollableChild,
    Widget? child,
    Side? transition,
    bool? isSubmitting,
  }) {
    emit(PaneState(
      active: active ?? state.active,
      height: height ?? state.height,
      child: child ?? state.child,
      scrollableChild: scrollableChild ?? state.scrollableChild,
      transition: transition ?? state.transition,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void removeChild() {
    emit(PaneState(
      active: state.active,
      height: state.height,
      child: null,
      scrollableChild: state.scrollableChild,
      transition: state.transition,
      isSubmitting: state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void removeScrollableChild() {
    emit(PaneState(
      active: state.active,
      height: state.height,
      child: state.child,
      scrollableChild: null,
      transition: state.transition,
      isSubmitting: state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  void removeChildren() {
    emit(PaneState(
      active: state.active,
      height: state.height,
      child: null,
      scrollableChild: null,
      transition: state.transition,
      isSubmitting: state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }
}
