import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wallet_utils/src/transaction.dart' as wutx;
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_front/application/common.dart';

part 'state.dart';

class SimpleCreateFormCubit extends Cubit<SimpleCreateFormState> {
  SimpleCreateFormCubit() : super(SimpleCreateFormState());

  void reset() => emit(SimpleCreateFormState());

  void submitting() => update(isSubmitting: true);

  void update({
    SymbolType? type,
    String? parentName,
    String? name,
    String? memo,
    int? quantity,
    int? decimals,
    bool? reissuable,
    List<UnsignedTransactionResult>? unsigned,
    List<wutx.Transaction>? signed,
    List<String>? txHash,
    SimpleCreateCheckoutForm? checkout,
    bool? isSubmitting,
  }) =>
      emit(SimpleCreateFormState(
        type: type ?? state.type,
        parentName: parentName ?? state.parentName,
        name: name ?? state.name,
        memo: memo ?? state.memo,
        quantity: quantity ?? state.quantity,
        decimals: decimals ?? state.decimals,
        reissuable: reissuable ?? state.reissuable,
        unsigned: unsigned ?? state.unsigned,
        signed: signed ?? state.signed,
        txHash: txHash ?? state.txHash,
        checkout: checkout ?? state.checkout,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      ));

  // need set unsigned tx
  // need verify
  // need sign
  // need broadcast
}
