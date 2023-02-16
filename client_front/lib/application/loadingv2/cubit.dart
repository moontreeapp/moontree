import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class LoadingViewCubitv2 extends Cubit<LoadingViewStatev2> {
  String? priorPage;

  LoadingViewCubitv2() : super(LoadingViewStatev2.initial());

  Future<void> reset() async => emit(LoadingViewStatev2.initial());

  LoadingViewStatev2 submitting() => state.load(isSubmitting: true);

  Future<void> enter() async {
    emit(state);
  }

  void set({
    LoadingStatusv2? status,
    LoadingStatusv2? priorStatus,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      priorStatus: priorStatus,
      isSubmitting: isSubmitting,
    ));
  }

  void setStatus({
    LoadingStatusv2? status,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      priorStatus: state.status,
      isSubmitting: isSubmitting,
    ));
  }

  void show() {
    set(status: LoadingStatusv2.busy, priorStatus: state.status);
  }

  void hide() {
    set(status: LoadingStatusv2.none, priorStatus: state.status);
  }

  bool get shouldShow => [LoadingStatusv2.busy].contains(state.status);

  bool get showing =>
      state.status == LoadingStatusv2.busy &&
      state.priorStatus == LoadingStatusv2.none;
  bool get shown =>
      state.status == LoadingStatusv2.busy &&
      state.priorStatus == LoadingStatusv2.busy;
  bool get hidding =>
      state.status == LoadingStatusv2.none &&
      state.priorStatus == LoadingStatusv2.busy;
  bool get hidden =>
      state.status == LoadingStatusv2.none &&
      state.priorStatus == LoadingStatusv2.none;
  bool get moving => showing || hidding;
}
