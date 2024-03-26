import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

final DraggableScrollableController draggableScrollController =
    DraggableScrollableController();

class PaneCubit extends Cubit<PaneState> with UpdateHideMixin<PaneState> {
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
    bool? dispose,
    double? height,
    double? initial,
    double? min,
    double? max,
    ScrollController? scroller,
    DraggableScrollableController? controller,
    bool? isSubmitting,
    PaneState? prior,
  }) {
    if (scroller != null) {
      scroller.addListener(_scrollListener);
    }
    emit(PaneState(
      active: active ?? state.active,
      dispose: dispose ?? false,
      height: height ?? state.height,
      initial: initial ?? state.initial,
      min: min ?? state.min,
      max: max ?? state.max,
      scroller: scroller ?? state.scroller,
      controller: controller ?? state.controller,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  void dispose() => update(dispose: true);
  bool unattached() => state.scroller?.positions.isEmpty ?? true;

  void _scrollListener() {
    //  if (state.scroller != null && state.scroller!.positions.isEmpty) return;
    print(state.scroller!.offset);
  }
}
