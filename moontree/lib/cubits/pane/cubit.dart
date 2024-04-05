import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';
part 'state.dart';

final DraggableScrollableController draggableScrollController =
    DraggableScrollableController();

class PaneCubit extends Cubit<PaneState> with UpdateHideMixin<PaneState> {
  PaneCubit() : super(PaneState(controller: draggableScrollController));
  double height = 0;
  void Function(double height)? heightBehavior;
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
    this.height = height ?? this.height;
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
    height = state.controller.sizeToPixels(state.controller.size);
    print(height);
    heightBehavior?.call(height);
    // this works ok, but is snap-mid drag and comes with the side effect of
    // not being able to flick it up or down all the way smoothly, it will snap
    // to the midde first, furthermore, there's a nasty staccato effect.
    //_draggableSnap(height);
  }

  //void _draggableSnap(double height) {
  //  final double snapTo = [
  //    screen.pane.maxHeight,
  //    screen.pane.midHeight,
  //    screen.pane.minHeight,
  //  ].reduce((a, b) => (height - a).abs() < (height - b).abs() ? a : b);
  //  if (height != snapTo) {
  //    print('oh snap! $snapTo');
  //    update(height: snapTo);
  //  }
  //}

  void snapTo(double heightPixels) {
    if (height == heightPixels && state.height == heightPixels) return;
    if (heightPixels == screen.pane.minHeight) {
      try {
        state.scroller?.jumpTo(0);
      } catch (_) {}
    }
    if (state.height == heightPixels) {
      update(height: heightPixels + 1);
    }
    update(height: heightPixels);
  }
}
