import 'package:bloc/bloc.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:wallet_utils/wallet_utils.dart' show satsPerCoin;
import 'package:wallet_utils/src/transaction.dart' as wutx;
import 'package:client_back/streams/app.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_front/infrastructure/calls/broadcast.dart';

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
    int? fee,
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
        fee: fee ?? state.fee,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      ));

  // need set unsigned tx
  Future<void> updateUnsignedTransaction({
    required String symbol,
    required Wallet wallet,
    required Chain chain,
    required Net net,
  }) async {}

  // need verify
  Future<Tuple2<bool, String?>> verifyTransaction() async {
    return Tuple2(true, '');
  }

  // need sign
  Future<void> sign() async {}

  /// actually commit transaction
  Future<void> broadcast() async {
    if (state.signed == null) {
      print('transaction not signed yet');
      return;
    }
    for (final wutx.Transaction signed in state.signed ?? []) {
      print('broadcasting ${signed.toHex()}');

      /// should we use a repository for this? why? myabe for validation purposes?
      /// and for saving the note in success case? we'd still do the rest here...
      /// todo: do repo pattern I guess..
      final broadcastResult = (await BroadcastTransactionCall(
        rawTransactionHex: signed.toHex(),
        chain: pros.settings.chain,
        net: pros.settings.net,
      )());

      // todo: should we do more validation on the txHash?
      if (broadcastResult.value != null && broadcastResult.error == null) {
        update(txHash: [...state.txHash ?? [], broadcastResult.value!]);
        Future.delayed(Duration(seconds: 2)).then((_) =>
            streams.app.behavior.snack.add(Snack(
                positive: true,
                message: 'Successfully Sent Transaction',
                copy: broadcastResult.value!)));
      } else {
        Future.delayed(Duration(seconds: 2)).then((_) =>
            streams.app.behavior.snack.add(Snack(
                positive: false,
                message: 'Unable to Send, Try again Later',
                copy: broadcastResult.error)));
      }
    }
  }
}
