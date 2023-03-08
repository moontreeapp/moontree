import 'package:bloc/bloc.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_front/infrastructure/repos/unsigned.dart';
import 'package:flutter/material.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show AmountToSatsExtension, FeeRate, standardFee;
import 'package:client_back/client_back.dart';
import 'package:client_front/application/common.dart';

part 'state.dart';

class SimpleSendFormCubit extends Cubit<SimpleSendFormState>
    with SetCubitMixin {
  SimpleSendFormCubit() : super(SimpleSendFormState.initial());

  @override
  Future<void> reset() async => emit(SimpleSendFormState.initial());

  @override
  SimpleSendFormState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
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
    UnsignedTransactionResult? unsigned,
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
      unsigned: unsigned,
      isSubmitting: isSubmitting,
    ));
  }

  Future<void> setUnsignedTransaction({
    Wallet? wallet,
    String? symbol,
    Chain? chain,
    Net? net,
  }) async {
    set(
      isSubmitting: true,
    );
    UnsignedTransactionResult unsigned = await UnsignedTransactionRepo(
      wallet: wallet,
      symbol: symbol ?? state.security.symbol,
      security: state.security,
      feeRate: state.fee,
      sats: state.sats,
      address: state.address,
      chain: chain,
      net: net,

      /// what should I do with these?
      //String? memo,
      //String? note,
      //String? addressName,
    ).fetch(only: true);
    set(
      unsigned: unsigned,
      isSubmitting: false,
    );
  }

  //void clearCache() => set(
  //      unsigned: null,
  //    );

  //void submit() async {
  //  emit(await submitSend());
  //}

  /*
  TODO:
  // convertion to txb so we can sign it
  transactionBuilder.fromTransaction(Transaction.fromBuffer(our hex.toUint8List())) -> txb object 
  hex -> get addresses, amounts, etc we're sending too (details)
  hex + other -> sign -> signed tx -> endpoint
  
  // will call on each value:
  signRaw({
    required int vin, // from unsigned tx
    required ECPair keyPair, // from unsigned tx
    int? hashType,
    Uint8List? prevOutScriptOverride, // from unsigned tx
  })
  */
}
