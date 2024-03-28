import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';
import 'package:moontree/services/services.dart';

part 'state.dart';

final DraggableScrollableController draggableScrollController =
    DraggableScrollableController();

class PaneCubit extends Cubit<PaneState> with UpdateHideMixin<PaneState> {
  PaneCubit() : super(PaneState(controller: draggableScrollController));
  double height = 0;
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
    //if (scroller != null) {
    //  scroller.removeListener(_scrollListener);
    //  scroller.addListener(_scrollListener);
    //}
    if (controller != null) {
      controller.removeListener(_controllerListener);
      controller.addListener(_controllerListener);
    }
    this.height = height ?? state.height;
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

  //void _scrollListener() {
  //  // something here could be used for pagination triggers...
  //  //  if (state.scroller != null && state.scroller!.positions.isEmpty) return;
  //  print(state.scroller!.position.viewportDimension);
  //  print(state.scroller!.offset);
  //}

  void _controllerListener() {
    //  if (state.scroller != null && state.scroller!.positions.isEmpty) return;
    height = state.controller.sizeToPixels(state.controller.size);
  }

  void toggleFull() {
    try {
      state.scroller?.jumpTo(0);
    } catch (_) {}
    if (height <= screen.pane.midHeight) {
      if (state.height == screen.pane.maxHeight) {
        update(height: screen.pane.maxHeight - 1);
      }
      update(height: screen.pane.maxHeight);
    } else {
      if (state.height == screen.pane.minHeight) {
        update(height: screen.pane.minHeight + 1);
      }
      update(height: screen.pane.minHeight);
    }
  }
}
