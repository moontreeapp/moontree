import 'dart:math';

import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_front/infrastructure/services/client/asset_metadata.dart';
import 'package:flutter/material.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/infrastructure/services/client/transactions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:client_back/client_back.dart';
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
    String? page,
    bool? isSubmitting,
  }) {
    emit(state.load(
      status: status,
      page: page,
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
