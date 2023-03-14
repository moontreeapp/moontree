import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_back/services/transaction/verify.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/calls/broadcast.dart';
import 'package:client_front/infrastructure/repos/receive.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:tuple/tuple.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show
        AmountToSatsExtension,
        ECPair,
        FeeRate,
        TransactionBuilder,
        evrmoreMainnet,
        parseSendAmountAndFeeFromSerializedTransaction,
        satsPerCoin,
        standardFee;
import 'package:wallet_utils/src/transaction.dart' as wutx;
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_front/infrastructure/repos/unsigned.dart';
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
    String? changeAddress,
    String? addressName,
    UnsignedTransactionResult? unsigned,
    wutx.Transaction? signed,
    String? txHash,
    SimpleSendCheckoutForm? checkout,
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
      changeAddress: changeAddress,
      addressName: addressName,
      unsigned: unsigned,
      signed: signed,
      txHash: txHash,
      checkout: checkout,
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
    chain ??= Current.chain;
    net ??= Current.net;
    final changeAddress =
        (await ReceiveRepo(wallet: wallet).fetch()).address(chain, net);
    UnsignedTransactionResult unsigned = await UnsignedTransactionRepo(
      wallet: wallet,
      symbol: symbol ?? state.security.symbol,
      security: state.security,
      feeRate: state.fee,
      sats: state.sats,
      changeAddress: changeAddress,
      address: state.address,
      memo: state.memo,
      chain: chain,
      net: net,

      /// todo: eventually we'll make a system to have accounts serverside, and
      ///       this will be relevant. until then, keep it as a reminder
      //String? addressName,
    ).fetch(only: true);
    set(
      unsigned: unsigned,
      changeAddress: changeAddress,
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
  TransactionBuilder.fromTransaction(Transaction.fromBuffer(our hex.toUint8List())) -> txb object 
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

  /// get fee, change, and sending amount from the raw hex, save to state.
  /// convert to TransactionBuilder object, inspect
  Future<bool> sign() async {
    final txb = TransactionBuilder.fromRawInfo(
        state.unsigned!.rawHex,
        state.unsigned!.vinScriptOverride.map((e) => e?.hexBytes),
        state.unsigned!.vinLockingScriptType.map(
            (e) => e == -1 ? null : ['pubkeyhash', 'scripthash', 'pubkey'][e]),
        state.security.chainNet.network //  evrmoreMainnet.
        );
    for (final Tuple2<int, String> e
        in state.unsigned!.vinPrivateKeySource.enumeratedTuple<String>()) {
      ECPair? keyPair;
      if (e.item2.contains(':')) {
        final walletPubKeyAndDerivationIndex = e.item2.split(':');
        // todo Current.wallet must be LeaderWallet, if not err?
        keyPair = await services.wallet.getAddressKeypair(
            await services.wallet.leader.deriveAddressByIndex(
          wallet: Current.wallet as LeaderWallet,
          exposure: walletPubKeyAndDerivationIndex[0] ==
                  (await (Current.wallet as LeaderWallet).roots)[0]
              ? NodeExposure.external
              : NodeExposure.internal,
          hdIndex: int.parse(walletPubKeyAndDerivationIndex[1]),
          chain: state.security.chain,
          net: state.security.net,
        ));
      } else {
        /// case for SingleWallet
        /// in theory we shouldn't have to use the h160 to figureout which
        /// address since the current wallet is the one that made this
        /// transaction, it should always match the h160 provided
        if (e.item2 !=
            (Current.wallet as SingleWallet).addresses.first.h160AsString) {
          throw Exception(
              ("Single wallet signing erorr: wallet doens't match h160 returned from server\n"
                  "h160: ${e.item2}"
                  "local: ${(Current.wallet as SingleWallet).addresses.first.h160AsString}"));
        }
        keyPair = await services.wallet.getAddressKeypair(
            (Current.wallet as SingleWallet).addresses.first);
      }
      txb.sign(
        vin: e.item1,
        keyPair: keyPair,
        hashType: null,
        prevOutScriptOverride:
            state.unsigned!.vinScriptOverride[e.item1]?.hexBytes,
      );
    }
    final tx = txb.build();
    print(tx);
    set(signed: tx);
    // compare this against parsed fee amount to verify fee.
    print(tx.fee(goal: state.fee));
    return false;
  }

  ///
  Future<TransactionComponents> processHex() async {
    /*
    bool parsed() {
      final Map<String, Tuple2<String?, int>> cryptoAssetSatsByVinTxPos =
          <String, Tuple2<String?, int>>{};
      for (final Vout utxo in /*estimate.utxos*/ [
        //Vout(
        //  toAddress: state.address,
        //  /*String*/ transactionId: state.unsigned.transactionId,
        //  /*int*/ position: state.unsigned.position,
        //  /*String*/ type: state.unsigned.vinLockingScriptType,
        //  /*int*/ coinValue: state.amount,
        //  /*String?*/ assetSecurityId: state.security
        //)
      ]) {
        //state.unsigned.vinPrivateKeySource // should have transactionIds and positions implied, need amounts.
        cryptoAssetSatsByVinTxPos['${utxo.transactionId}:${utxo.position}'] =
            Tuple2<String?, int>(
                utxo.isAsset ? utxo.security!.symbol : null, utxo.coinValue);
      }
      final Tuple2<Map<String?, int>, int> result =
          parseSendAmountAndFeeFromSerializedTransaction(
        cryptoAssetSatsByVinTxPos,
        state.unsigned!.rawHex.hexDecode,
      );
      // todo also check item1 against state.
      if (result.item2 > 2 * satsPerCoin) {
        throw FeeGuardException('Parsed fee too large.');
      }
      return true;
    }

    // old way:
    //return parsed();
    // or process txb or tx from sign
    */

    /// new way:
    int getFee() {
      // sum the vinAmounts that are evr
      final coinInputs = state.unsigned!.vinAmounts
          .where((e) => e.contains('null:'))
          .map((e) => int.parse(e.split('null:').last))
          .sum();
      print(coinInputs);
      // parsed transaction vouts that are evr (txb.vouts.sum that are evr)
      print(state.signed!.outs);
      print(state.signed!.outs.map((e) => e.value));
      print(state.signed!.outs.map((e) => e.valueBuffer));
      print(state.signed!.outs.map((e) => e.script));
      print(state.signed!.outs.map((e) => e.signatures));
      print(state.signed!.outs.map((e) => e.pubkeys));

      // subtract the outputs that are = fee amount ???
      // (should equal feerate*tx.virtual bytes or something)
      //?state.unsigned!.vinAmounts.where((e) => !e.contains('null:')).sum();
      return 0;
    }

    String getTargetAddress() {
      return '';
    }

    String getChangeAddress() {
      return '';
    }

    return TransactionComponents(
        fee: getFee(),
        targetAddress: getTargetAddress(),
        changeAddress: getChangeAddress());
  }

  /// verify fee, sending to address, and return address
  Future<bool> verifyTransaction() async {
    final transactionComponents = await processHex();
    final ret = (
            // no transaction should cost more than 2 coins
            transactionComponents.feeSanityCheck &&
                // our estimate a of the fee should be close to the fee the server calculated,
                // which should be equal to next condition, by the way.
                transactionComponents.fee <=
                    state.fee.rate *
                        state.signed!.fee(goal: state.fee) *
                        1.01 &&
                // just double checking...
                transactionComponents.fee <=
                    (state.fee.rate * state.signed!.virtualSize()) * 1.01 &&
                // send the value to our intended address
                transactionComponents.targetAddress == state.address &&
                // send the change back to us
                transactionComponents.changeAddress == state.changeAddress //&&
        // todo: what about send amount?
        //transactionComponents.sendAmount == state.sats
        // todo: what about change amount?
        //transactionComponents.changeAmount == transactionComponents.totalOut - transactionComponents.sendAmount - transactionComponents.fee
        );
    if (ret) {
      // update checkout struct to update checkout page
      set(
        checkout: state.checkout!.newEstimate(
          SendEstimate(
            state.sats,
            sendAll: state.checkout!.estimate!.sendAll,
            fees: transactionComponents.fee,
            // not necessary
            //utxos: null, // in string form at cubit.state.unsigned.vinPrivateKeySource
            security: state.security,
            //assetMemo: Uint8List.fromList(cubit.state.memo
            //    .codeUnits), // todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
            memo: state.memo,
            creation: false,
          ),
        ),
      );
    }
    return ret;
  }

  /// actually commit transaction
  Future<void> broadcast() async {
    if (state.signed == null) {
      print('transaction not signed yet');
      return;
    }

    /// should we use a repository for this? why? myabe for validation purposes?
    /// and for saving the note in success case? we'd still do the rest here...
    /// todo: do repo pattern I guess..
    final broadcastResult = (await BroadcastTransactionCall(
      rawTransactionHex: state.signed!.toHex(),
      chain: state.security.chain,
      net: state.security.net,
    )());

    // todo: should we do more validation on the txHash?
    if (broadcastResult.value != null && broadcastResult.error == null) {
      set(txHash: broadcastResult.value);
      // todo: save note by this txHash here
      // should this be in a repo?
      pros.notes.save(Note(note: state.note, transactionId: state.txHash!));
      streams.app.snack.add(Snack(
          positive: true,
          message: 'Successfully Sent Transaction',
          copy: state.txHash));
    } else {
      streams.app.snack.add(Snack(
          positive: false,
          message: 'Unable to Send, Try again Later',
          copy: broadcastResult.error));
    }
  }
}

class TransactionComponents {
  final int fee;
  final String targetAddress; // assumes we're only sending to 1 address
  final String changeAddress;
  const TransactionComponents({
    required this.fee,
    required this.targetAddress,
    required this.changeAddress,
  });

  bool get feeSanityCheck => fee < 2 * satsPerCoin;
}

/// todo should come from wallet uils
//enum LockingScriptType { p2pkh, p2sh, p2pk }
//const SCRIPT_TYPES = {
//  'P2SM': 'multisig',
//  'NONSTANDARD': 'nonstandard',
//  'NULLDATA': 'nulldata',
//  'P2PK': 'pubkey',
//  'P2PKH': 'pubkeyhash',
//  'P2SH': 'scripthash',
//  'P2WPKH': 'witnesspubkeyhash',
//  'P2WSH': 'witnessscripthash',
//  'WITNESS_COMMITMENT': 'witnesscommitment'
//};
