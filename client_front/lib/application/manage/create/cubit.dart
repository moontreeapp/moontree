import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wallet_utils/src/transaction.dart' as wutx;
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_front/application/common.dart';

part 'state.dart';

class SimpleCreateFormCubit extends Cubit<SimpleCreateFormState>
    with SetCubitMixin {
  SimpleCreateFormCubit() : super(SimpleCreateFormState.initial());

  @override
  Future<void> reset() async => emit(SimpleCreateFormState.initial());

  @override
  SimpleCreateFormState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(submitting());
    emit(state);
  }

  @override
  void set({
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
  }) {
    emit(state.load(
      type: type,
      parentName: parentName,
      name: name,
      memo: memo,
      quantity: quantity,
      decimals: decimals,
      reissuable: reissuable,
      unsigned: unsigned,
      signed: signed,
      txHash: txHash,
      checkout: checkout,
      isSubmitting: isSubmitting,
    ));
  }

  // need set unsigned tx
  // need verify
  // need sign
  // need broadcast
}
