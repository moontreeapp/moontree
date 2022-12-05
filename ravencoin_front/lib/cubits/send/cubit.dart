import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wallet_utils/wallet_utils.dart' show FeeRate, standardFee;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/cubits/parents.dart';

part 'state.dart';

class SimpleSendFormCubit extends Cubit<SimpleSendFormState>
    with SetCubitMixin {
  SimpleSendFormCubit() : super(SimpleSendFormState.initial());

  @override
  void reset() async => emit(SimpleSendFormState.initial());

  @override
  SimpleSendFormState submitting() => state.load(isSubmitting: true);

  @override
  void enter() async {
    emit(submitting());
    emit(state);
  }

  @override
  void set({
    Security? security,
    String? address,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? addressName,
    bool? isSubmitting,
  }) {
    emit(submitting());
    emit(state.load(
      security: security,
      address: address,
      amount: amount,
      fee: fee,
      memo: memo,
      note: note,
      addressName: addressName,
      isSubmitting: isSubmitting,
    ));
  }

  //void submit() async {
  //  emit(await submitSend());
  //}
}
