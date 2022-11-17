import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

part 'state.dart';

class SimpleSendForm extends Cubit<SimpleSendFormState> {
  SimpleSendForm() : super(SimpleSendFormState.initial());

  SimpleSendFormState submitting() => state.load(isSubmitting: true);

  Future<SimpleSendFormState> set(
    String? symbol,
    double? amount,
    String? fee,
    String? note,
    String? address,
    String? addressName,
    bool? isSubmitting,
  ) async =>
      state.load(
        symbol: symbol,
        amount: amount,
        fee: fee,
        note: note,
        address: address,
        addressName: addressName,
        isSubmitting: isSubmitting,
      );

  //void enter() async {
  //  emit(await load());
  //}

  //void submit() async {
  //  emit(await submitSend());
  //}
}
