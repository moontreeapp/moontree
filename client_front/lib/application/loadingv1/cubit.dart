import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/common.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class LoadingViewV1Cubit extends Cubit<LoadingViewV1State> with SetCubitMixin {
  String? priorPage;

  LoadingViewV1Cubit() : super(LoadingViewV1State.initial()) {
    init();
  }

  @override
  Future<void> reset() async => emit(LoadingViewV1State.initial());

  @override
  LoadingViewV1State submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    LoadingStatusV1? status,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    /// will probably need some kind of listeners, maybe depending on page.
    //streams.app.loc.page.listen((String value) {
    //  if (value == 'Home' && priorPage == 'Transactions') {
    //    reset();
    //  }
    //  priorPage = value;
    //});
  }

  bool get shouldShow => [LoadingStatusV1.busy].contains(state.status);
}
