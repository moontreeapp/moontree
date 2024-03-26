import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';

part 'state.dart';

final DraggableScrollableController draggableScrollController =
    DraggableScrollableController();

class PaneCubit extends Cubit<PaneState> with UpdateSectionMixin<PaneState> {
  PaneCubit() : super(PaneState(controller: draggableScrollController));
  @override
  String get key => 'pane';
  @override
  void reset() => emit(PaneState(controller: draggableScrollController));
  @override
  void setState(PaneState state) => emit(state);
  void refresh() => update(isSubmitting: true);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    double? height,
    double? initial,
    double? min,
    double? max,
    Widget? child,
    Widget Function(ScrollController)? scrollableChild,
    DraggableScrollableController? controller,
    Side? transition,
    bool? isSubmitting,
  }) {
    emit(PaneState(
      active: active ?? state.active,
      initial: initial ?? state.initial,
      min: min ?? state.min,
      max: max ?? state.max,
      controller: controller ?? state.controller,
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
      initial: state.initial,
      min: state.min,
      max: state.max,
      controller: state.controller,
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
      initial: state.initial,
      min: state.min,
      max: state.max,
      controller: state.controller,
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
      initial: state.initial,
      min: state.min,
      max: state.max,
      controller: state.controller,
      child: null,
      scrollableChild: null,
      transition: state.transition,
      isSubmitting: state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }
}
