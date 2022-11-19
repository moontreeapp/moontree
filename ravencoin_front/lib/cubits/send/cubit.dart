import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/cubits/state.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show FeeRate, FeeRates, standardFee, cheapFee, fastFee;
import 'package:moontree_utils/zips.dart' show zipLists;

part 'state.dart';

class SimpleSendFormCubit extends Cubit<SimpleSendFormState> {
  SimpleSendFormCubit() : super(SimpleSendFormState.initial());

  SimpleSendFormState submitting() => state.load(isSubmitting: true);

  Future<SimpleSendFormState> set(
    Security? security,
    String? address,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? addressName,
    bool? isSubmitting,
  ) async =>
      state.load(
        security: security,
        address: address,
        amount: amount,
        fee: fee,
        memo: memo,
        note: note,
        addressName: addressName,
        isSubmitting: isSubmitting,
      );

  void enter() async => emit(state);

  //void submit() async {
  //  emit(await submitSend());
  //}
}
