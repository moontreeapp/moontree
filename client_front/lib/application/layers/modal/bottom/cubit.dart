// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

part 'state.dart';

class BottomModalSheetCubit extends Cubit<BottomModalSheetCubitState> {
  double height = 0;
  BottomModalSheetCubit()
      : super(const BottomModalSheetState(
          display: false,
          exiting: false,
          children: <Widget>[],
          childrenHeight: 52,
          fullscreen: false,
          color: Colors.white,
        ));

  void reset() => emit(const BottomModalSheetState(
        display: false,
        exiting: false,
        children: <Widget>[],
        childrenHeight: 52,
        fullscreen: false,
        color: Colors.white,
      ));

  void show({
    List<Widget>? children,
    int? childrenHeight,
    bool? fullscreen,
    Color? color,
  }) =>
      emit(BottomModalSheetState(
        display: true,
        exiting: false,
        children: children == null
            ? state.children
            : children + [SizedBox(height: 8)],
        childrenHeight: childrenHeight ?? state.childrenHeight,
        fullscreen: fullscreen ?? state.fullscreen,
        color: color ?? state.color,
      ));

  Future<void> hide() async {
    emit(BottomModalSheetState(
      display: true,
      exiting: true,
      children: state.children,
      childrenHeight: state.childrenHeight,
      fullscreen: state.fullscreen,
      color: state.color,
    ));
    await Future.delayed(animation.slideDuration);
    emit(BottomModalSheetState(
      display: false,
      exiting: false,
      children: state.children,
      childrenHeight: state.childrenHeight,
      fullscreen: state.fullscreen,
      color: state.color,
    ));
    await Future.delayed(animation.slideDuration);
    reset();
  }

  void hideNow() => emit(BottomModalSheetState(
        display: false,
        exiting: false,
        children: state.children,
        childrenHeight: state.childrenHeight,
        fullscreen: state.fullscreen,
        color: state.color,
      ));

  /// height of the list of options - referenced but must to not trigger rebuild
  void setHeight(double h) => height = h;

  /// ListTitle with a 24x24 icon is 52 pixels tall, if you provide a different
  /// type of children you'll have to override the childrenHeight
  void overrideChildrenHeight(int height) => emit(BottomModalSheetState(
        display: state.display,
        exiting: state.exiting,
        children: state.children,
        childrenHeight: height,
        fullscreen: state.fullscreen,
        color: state.color,
      ));
}
