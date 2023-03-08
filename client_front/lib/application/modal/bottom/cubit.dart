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
        ));

  void show({List<Widget>? children}) => emit(BottomModalSheetState(
        display: true,
        exiting: false,
        children: children ?? state.children,
        childrenHeight: state.childrenHeight,
      ));

  Future<void> hide() async {
    emit(BottomModalSheetState(
      display: true,
      exiting: true,
      children: state.children,
      childrenHeight: state.childrenHeight,
    ));
    await Future.delayed(animation.slideDuration);
    emit(BottomModalSheetState(
      display: false,
      exiting: false,
      children: state.children,
      childrenHeight: state.childrenHeight,
    ));
  }

  void hideNow() => emit(BottomModalSheetState(
        display: false,
        exiting: false,
        children: state.children,
        childrenHeight: state.childrenHeight,
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
      ));
}
