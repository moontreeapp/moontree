import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:client_back/services/transaction/verify.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/calls/broadcast.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
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
    String? addressName,
    UnsignedTransactionResult? unsigned,
    wutx.Transaction? signed,
    String? txHash,
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
      signed: signed,
      txHash: txHash,
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
    print(txb.chainName);
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
        // case for SingleWallet
        final h160 = e.item2;
        // h160 -> address.keypair
        //(Current.wallet as SingleWallet).addresses.first.
      }
      txb.sign(
        vin: e.item1,
        keyPair: keyPair!,
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
  Future<void> processHex() async {
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

    //return parsed();
    // or process txb or tx from sign

    // sum the vinAmounts that are evr
    state.unsigned!.vinAmounts.where((e) => e.contains('null:')).sum(); //split
    // parsed transaction vouts that are evr (txb.vouts.sum that are ever)
    // subtract the outputs that are = fee amount
    // (should equal feerate*tx.virtual bytes or something)
    //?state.unsigned!.vinAmounts.where((e) => !e.contains('null:')).sum();
  }

  ///
  Future<void> broadcast() async {
    if (state.signed == null) {
      print('transaction not signed yet');
      return;
    }

    /// should we use a repository for this? why?
    set(
        txHash: (await BroadcastTransactionCall(
      rawTransactionHex: state.signed!.toHex(),
      chain: state.security.chain,
      net: state.security.net,
    )())
            .value);
    streams.app.snack.add(Snack(
        positive: true,
        message: 'Successfully Sent Transaction',
        copy: state.txHash));
  }
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
