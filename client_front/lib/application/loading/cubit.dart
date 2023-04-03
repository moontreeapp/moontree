import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/common.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class LoadingViewCubit extends Cubit<LoadingViewState> with SetCubitMixin {
  String? priorPage;

  LoadingViewCubit() : super(LoadingViewState.initial()) {
    init();
  }

  @override
  Future<void> reset() async => emit(LoadingViewState.initial());

  @override
  LoadingViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    LoadingStatus? status,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    /// will probably need some kind of listeners, maybe depending on page.
    //streams.app.page.listen((String value) {
    //  if (value == 'Home' && priorPage == 'Transactions') {
    //    reset();
    //  }
    //  priorPage = value;
    //});
  }

  bool get shouldShow => [LoadingStatus.busy].contains(state.status);
}
