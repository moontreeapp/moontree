import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/repos/receive.dart';
import 'package:client_front/application/common.dart';
part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class ReceiveViewCubit extends Cubit<ReceiveViewState> with SetCubitMixin {
  ReceiveViewCubit() : super(ReceiveViewState.initial());

  @override
  Future<void> reset() async => emit(ReceiveViewState.initial());

  @override
  ReceiveViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    //emit(submitting());
    emit(state);
  }

  @override
  void set({
    Address? address,
    bool? isSubmitting,
  }) {
    emit(state.load(
      address: address,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> setAddress(
    Wallet wallet, {
    bool force = false,
  }) async {
    if (force || state.address == null) {
      set(
        address: null,
        isSubmitting: true,
      );
      final address = await ReceiveRepo(wallet: wallet).fetch();
      set(
        address: address,
        isSubmitting: false,
      );
    }
  }

  String get address =>
      state.address?.address(pros.settings.chain, pros.settings.net) ??
      'generating...';

  void clearCache() => set(address: null);
}
