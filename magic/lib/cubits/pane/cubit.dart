import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/services/services.dart';
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

  void _controllerListener() {
    height = state.controller.sizeToPixels(state.controller.size);
    heightBehavior?.call(height);
  }

  void snapTo(double heightPixels, {bool force = false}) {
    if (height == heightPixels && state.height == heightPixels && !force)
      return;
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
