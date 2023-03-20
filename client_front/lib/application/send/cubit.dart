import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_front/infrastructure/repos/asset_metadata.dart';
import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:client_back/services/transaction/maker.dart';
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
    AssetMetadata? metadataView,
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
      metadataView: metadataView,
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

  // needed for validation of divisibility
  Future<void> setMetadataView({Security? security}) async => set(
        metadataView: (await AssetMetadataHistoryRepo(
                    security: security ?? state.security)
                .get())
            .firstOrNull,
        isSubmitting: false,
      );
  Future<AssetMetadata?> getMetadataView({Security? security}) async =>
      (await AssetMetadataHistoryRepo(security: security ?? state.security)
              .get())
          .firstOrNull;

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
        (await ReceiveRepo(wallet: wallet, change: true).fetch())
            .address(chain, net);
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

  /// convert to TransactionBuilder object, inspect
  Future<bool> sign() async {
    final txb = TransactionBuilder.fromRawInfo(
        state.unsigned!.rawHex,
        state.unsigned!.vinScriptOverride.map((e) => e?.hexBytes),
        state.unsigned!.vinLockingScriptType.map(
            (e) => e == -1 ? null : ['pubkeyhash', 'scripthash', 'pubkey'][e]),
        state.security.chainNet.network);
    print('state.unsigned!.vinAssets');
    print(state.unsigned!.vinAssets);
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
      txb.signRaw(
        vin: e.item1,
        keyPair: keyPair,
        hashType: null,
        prevOutScriptOverride:
            state.unsigned!.vinScriptOverride[e.item1]?.hexBytes,
        asset: state.unsigned!.vinAssets[e.item1],
        assetAmount: state.unsigned!.vinAmounts[e.item1],
        assetLiteral: Current.chainNet.chaindata.assetLiteral,
      );
    }
    final tx = txb.build();
    print(tx);
    set(signed: tx);
    // compare this against parsed fee amount to verify fee.
    print(tx.fee(goal: state.fee));
    return false;
  }

  /// parse transaction to verify elements within
  Future<TransactionComponents> processHex() async {
    int getFee() {
      // sum the vinAmounts that are evr
      final int coinInput = [
        for (final x in IterableZip([
          state.unsigned!.vinAssets,
          state.unsigned!.vinAmounts,
        ]))
          x[0] == null ? x[1] : 0
      ].sum() as int;
      print('coinInput');
      print(coinInput);
      //{code: -26, message: 16: mandatory-script-verify-flag-failed (Signature must be zero for failed CHECK(MULTI)SIG operation)}
      // parsed transaction vouts that are evr (txb.vouts.sum that are evr)
      // technically unnecessary to filer since assets will always have 0 value
      final int coinOutput = state.signed!.outs
          .where((e) => e.value != null && e.value! > 0) // filter to evr
          .map((e) => e.value)
          .sum() as int;

      print('with filter');
      print(state.signed!.outs
          .where((e) => e.value != null && e.value! > 0) // filter to evr
          .map((e) => e.value));
      print('without filter');
      print(state.signed!.outs.map((e) => e.value));

      print('coinOutput');
      print(coinOutput);

      // subtract the output from input for the fee amount.
      // (should equal feerate*tx.virtual bytes or something)
      final int coinFee = coinInput - coinOutput;
      print('coinFee');
      print(coinFee);
      /*
      print(state.signed!.outs);
      print(state.signed!.outs.map((e) => e.value));
      print(state.signed!.outs.map((e) => e.valueBuffer));
      print(state.signed!.outs.map((e) => e.script));
      print(state.signed!.outs.map((e) => e.signatures));
      print(state.signed!.outs.map((e) => e.pubkeys));

      I/flutter ( 5386): 16779064734
      /// don't know how to identifiy EVR outs... 
      I/flutter ( 5386): [
        Output{script: [118, 169, 20, 254, 203, 15, 108, 36, 248, 195, 38, 115, 211, 222, 2, 240, 179, 245, 96, 184, 44, 208, 180, 136, 172], value: 100000000, valueBuffer: null, pubkeys: null, signatures: null}, 
        Output{script: [118, 169, 20, 192, 83, 97, 158, 202, 96, 72, 25, 100, 187, 225, 130, 133, 66, 97, 184, 179, 83, 129, 129, 136, 172], value: 16678064734, valueBuffer: null, pubkeys: null, signatures: null}]
      I/flutter ( 5386): (100000000, 16678064734)
      I/flutter ( 5386): (null, null)
      I/flutter ( 5386): ([118, 169, 20, 254, 203, 15, 108, 36, 248, 195, 38, 115, 211, 222, 2, 240, 179, 245, 96, 184, 44, 208, 180, 136, 172], [118, 169, 20, 192, 83, 97, 158, 202, 96, 72, 25, 100, 187, 225, 130, 133, 66, 97, 184, 179, 83, 129, 129, 136, 172])
      I/flutter ( 5386): (null, null)
      I/flutter ( 5386): (null, null)

      // asset tx... value is 0, script is much longer...
      // also notice the in: 15674583 minus out: 14674583 is 1 evr. 
      // but evr should be the fee, we're trying to send 1 asset token... 
      // so shouldn't it be a fee amount, not 1 full evr? is there a mixup?
      // nvm that's not a unit, thats the minimum fee 1000000 sats
      I/flutter ( 5386): 15674583
      I/flutter ( 5386): [
        Output{script: [118, 169, 20, 254, 203, 15, 108, 36, 248, 195, 38, 115, 211, 222, 2, 240, 179, 245, 96, 184, 44, 208, 180, 136, 172, 192, 40, 116, 30, 83, 65, 84, 79, 82, 73, 35, 70, 79, 85, 78, 68, 65, 84, 73, 79, 78, 95, 82, 69, 80, 95, 84, 79, 75, 69, 78, 46, 95, 48, 0, 225, 245, 5, 0, 0, 0, 0, 117], value: 0, valueBuffer: null, pubkeys: null, signatures: null}, 
        Output{script: [118, 169, 20, 222, 228, 92, 57, 137, 96, 225, 183, 255, 241, 48, 239, 91, 214, 51, 126, 15, 218, 232, 65, 136, 172], value: 14674583, valueBuffer: null, pubkeys: null, signatures: null}]
      I/flutter ( 5386): (0, 14674583)
      I/flutter ( 5386): (null, null)
      I/flutter ( 5386): ([118, 169, 20, 254, 203, 15, 108, 36, 248, 195, 38, 115, 211, 222, 2, 240, 179, 245, 96, 184, 44, 208, 180, 136, 172, 192, 40, 116, 30, 83, 65, 84, 79, 82, 73, 35, 70, 79, 85, 78, 68, 65, 84, 73, 79, 78, 95, 82, 69, 80, 95, 84, 79, 75, 69, 78, 46, 95, 48, 0, 225, 245, 5, 0, 0, 0, 0, 117], [118, 169, 20, 222, 228, 92, 57, 137, 96, 225, 183, 255, 241, 48, 239, 91, 214, 51, 126, 15, 218, 232, 65, 136, 172])
      I/flutter ( 5386): (null, null)
      */

      return coinFee;
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
                (transactionComponents.fee <=
                        state.fee.rate *
                            state.signed!.fee(goal: state.fee) *
                            1.01 ||
                    // or is should not be bigger than the minimum fee
                    transactionComponents.fee <= FeeRate.minimumFee) //&&
        // todo: send the value to our intended address
        //transactionComponents.targetAddress == state.address &&
        // todo: send the change back to us
        //transactionComponents.changeAddress == state.changeAddress //&&
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
            security: state.security,
            memo: state.memo,
            creation: false,

            /// not necessary
            /// in string form at cubit.state.unsigned.vinPrivateKeySource
            //utxos: null,
            /// todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
            //assetMemo: Uint8List.fromList(cubit.state.memo
            //    .codeUnits),
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
