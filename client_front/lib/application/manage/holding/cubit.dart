import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'state.dart';

class ManageHoldingViewCubit extends Cubit<ManageHoldingViewState> {
  String? priorPage;

  ManageHoldingViewCubit() : super(ManageHoldingViewState.initial());

  Future<void> reset() async => emit(ManageHoldingViewState.initial());

  ManageHoldingViewState submitting() => state.load(isSubmitting: true);

  Future<void> enter() async {
    emit(state);
  }

  void set({
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) {
    emit(state.load(
      reachedTop: reachedTop,
      atBottom: atBottom,
      isSubmitting: isSubmitting,
    ));
  }

  void setStatus({
    bool? reachedTop,
    bool? isSubmitting,
  }) {
    emit(state.load(
      reachedTop: reachedTop,
      atBottom: state.reachedTop,
      isSubmitting: isSubmitting,
    ));
  }
}
