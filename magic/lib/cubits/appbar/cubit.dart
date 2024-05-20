// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class AppbarCubit extends UpdatableCubit<AppbarState> {
  AppbarCubit() : super(const AppbarState());
  @override
  String get key => 'appbar';
  @override
  void reset() => emit(const AppbarState());
  @override
  void setState(AppbarState state) => emit(state);
  @override
  void hide() {
    // TODO: implement hide
  }
  @override
  void refresh() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void update({
    AppbarLeading? leading,
    String? title,
    Widget? titleChild,
    VoidCallback? onLead,
    VoidCallback? onTitle,
    bool clearTitleChild = false,
    bool clearOnLead = false,
    bool clearOnTitle = false,
  }) {
    emit(AppbarState(
      leading: leading ?? state.leading,
      title: title ?? state.title,
      titleChild: titleChild ?? (clearTitleChild ? null : state.titleChild),
      onLead: onLead ?? (clearOnLead ? null : state.onLead) ?? none,
      onTitle: onTitle ?? (clearOnTitle ? null : state.onTitle) ?? none,
      prior: state.withoutPrior,
    ));
  }

  void none() {}
}
