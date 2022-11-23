import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/cubits/parents.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show FeeRate, FeeRates, standardFee, cheapFee, fastFee;
import 'package:moontree_utils/src/zips.dart' show zipLists;

part 'state.dart';

class SimpleSendFormCubit extends SetCubit<SimpleSendFormState> {
  SimpleSendFormCubit() : super(SimpleSendFormState.initial());

  @override
  Future<SimpleSendFormState> set({
    Security? security,
    String? address,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? addressName,
    bool? isSubmitting,
  }) async =>
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
}
