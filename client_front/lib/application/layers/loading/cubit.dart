import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class LoadingViewCubit extends Cubit<LoadingViewState> {
  String? priorPage;

  LoadingViewCubit() : super(LoadingViewState.initial());

  Future<void> reset() async => emit(LoadingViewState.initial());

  LoadingViewState submitting() => state.load(isSubmitting: true);

  Future<void> enter() async {
    emit(state);
  }

  void set({
    LoadingStatus? status,
    LoadingStatus? priorStatus,
    String? title,
    String? msg,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      priorStatus: priorStatus,
      title: title,
      msg: msg,
      isSubmitting: isSubmitting,
    ));
  }

  void setStatus({
    LoadingStatus? status,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      priorStatus: state.status,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> show({String? title, String? msg}) async {
    set(
        status: LoadingStatus.busy,
        priorStatus: state.status,
        title: title ?? state.title,
        msg: msg ?? state.msg);
    await Future.delayed(animation.slideDuration); // smooth loading slide
  }

  void hide() {
    set(
        status: LoadingStatus.none,
        priorStatus: state.status,
        title: null,
        msg: null);
  }

  Future<T> showDuring<T>(T Function() callback,
      {String? title, String? msg}) async {
    show(title: title, msg: msg);
    final T x = callback();
    hide();
    return x;
  }

  bool get shouldShow => [LoadingStatus.busy].contains(state.status);

  bool get showing =>
      state.status == LoadingStatus.busy &&
      state.priorStatus == LoadingStatus.none;
  bool get shown =>
      state.status == LoadingStatus.busy &&
      state.priorStatus == LoadingStatus.busy;
  bool get hidding =>
      state.status == LoadingStatus.none &&
      state.priorStatus == LoadingStatus.busy;
  bool get hidden =>
      state.status == LoadingStatus.none &&
      state.priorStatus == LoadingStatus.none;
  bool get moving => showing || hidding;
}
