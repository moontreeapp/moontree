import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin HideMixin<T> {
  void hide();
}

mixin UpdateResetMixin {
  String get key;
  void reset();
  void update();
}

mixin UpdateMixin<T> {
  void refresh();
  void activate();
  void deactivate();
  void setState(T state);
}

mixin DisposedMixin {
  void disposed();
  bool isDisposed();
}

mixin UpdateHideMixin<T>
    implements UpdateMixin<T>, UpdateResetMixin, HideMixin {}

abstract class UpdatingCubit<T> extends Cubit<T> with UpdateResetMixin {
  UpdatingCubit(super.initialState);
}

abstract class UpdatableCubit<T> extends Cubit<T> with UpdateHideMixin<T> {
  UpdatableCubit(super.initialState);
}

mixin PriorStateMixin<T> {
  T get withoutPrior;
}

mixin PriorActiveStateMixin<T> implements PriorStateMixin<T> {
  bool get wasActive; // !(prior?.active == null || !prior!.active);
  bool get isActive;
  bool get entering => !wasActive && isActive;
  bool get exiting => wasActive && !isActive;
  bool get entered => wasActive && isActive;
  bool get exited => !wasActive && !isActive;

  Widget transitionWidgets(
    PriorActiveStateMixin state, {
    required Widget onEntering,
    required Widget onEntered,
    required Widget onExiting,
    required Widget onExited,
  }) {
    if (state.entering) {
      return onEntering;
    }
    if (state.entered) {
      return onEntered;
    }
    if (state.exiting) {
      return onExiting;
    }
    // state.exited
    return onExited;
  }

  Widget transitionFunctions(
    PriorActiveStateMixin state, {
    required Widget Function() onEntering,
    required Widget Function() onEntered,
    required Widget Function() onExiting,
    required Widget Function() onExited,
  }) {
    if (state.entering) {
      return onEntering.call();
    }
    if (state.entered) {
      return onEntered.call();
    }
    if (state.exiting) {
      return onExiting.call();
    }
    // state.exited
    return onExited.call();
  }
}
