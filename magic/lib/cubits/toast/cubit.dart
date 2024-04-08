import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/presentation/utils/animation.dart';

part 'state.dart';

class ToastCubit extends Cubit<ToastState> with UpdateMixin<ToastState> {
  int counter = 0;
  ToastCubit() : super(const ToastState());
  @override
  String get key => 'toast';
  @override
  void reset() => emit(const ToastState());
  @override
  void setState(ToastState state) => emit(state);

  @override
  void update({
    VoidCallback? onTap,
    ToastMessage? msg,
    double? height,
    Duration? duration,
    ToastShowType? showType,
    int? toastId,
  }) {
    counter++;
    emit(ToastState(
      onTap: onTap ?? state.onTap ?? fadeAway,
      msg: msg ?? state.msg,
      height: height ?? state.height,
      duration: duration ?? state.duration,
      showType: showType ?? state.showType,
    ));
  }

  void flash({
    VoidCallback? onTap,
    ToastMessage? msg,
    double? height,
    Duration? duration,
    ToastShowType? showType,
  }) {
    reset();
    update(
      onTap: onTap,
      msg: msg,
      height: height,
      duration: duration,
      showType: showType,
    );
    final id = counter;
    Future.delayed(
        fadeDuration + state.duration + fadeDuration, maybeReset(id));
  }

  VoidCallback maybeReset(int id) {
    return () {
      if (counter == id) {
        reset();
      }
    };
  }

  void fadeAway() {
    update(showType: ToastShowType.fadeAway);
    Future.delayed(fadeDuration, reset);
  }
}
