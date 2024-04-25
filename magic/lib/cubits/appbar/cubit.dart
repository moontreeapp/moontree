// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:equatable/equatable.dart';
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
    VoidCallback? onLead,
    VoidCallback? onTitle,
  }) {
    emit(AppbarState(
      leading: leading ?? state.leading,
      title: title ?? state.title,
      onLead: onLead ?? state.onLead ?? none,
      onTitle: onTitle ?? state.onTitle ?? none,
      prior: state.withoutPrior,
    ));
  }

  void none() {}
}
