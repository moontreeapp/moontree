import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/presentation/utils/animation.dart';

part 'state.dart';

class ToastCubit extends UpdatableCubit<ToastState> {
  int counter = 0;
  bool suppress = false;
  ToastCubit() : super(const ToastState());
  @override
  String get key => 'toast';
  @override
  void reset() => emit(const ToastState());
  @override
  void setState(ToastState state) => emit(state);
  @override
  void refresh() {}
  @override
  void activate() => update(toastId: counter++);
  @override
  void deactivate() => update(toastId: counter++);

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
    if (suppress && (msg == null || !msg.force)) return;
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

  @override
  void hide() {
    // TODO: implement hide
  }
}
