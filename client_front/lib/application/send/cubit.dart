import 'dart:convert';
import 'dart:typed_data';

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
      // server decides fast:
      feeRate: state.fee == standardFee ? state.fee : null,
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
    /// sum the vinAmounts that are evr
    int getCoinInput() => [
          for (final x in IterableZip([
            state.unsigned!.vinAssets,
            state.unsigned!.vinAmounts,
          ]))
            x[0] == null ? x[1] : 0
        ].sum() as int;

    int getCoinFee(int coinInput) {
      //{code: -26, message: 16: mandatory-script-verify-flag-failed (Signature must be zero for failed CHECK(MULTI)SIG operation)}
      // parsed transaction vouts that are evr (txb.vouts.sum that are evr)
      // technically unnecessary to filer since assets will always have 0 value
      final int coinOutput = state.signed!.outs
          .where((e) => e.value != null && e.value! > 0) // filter to evr
          .map((e) => e.value)
          .sum() as int;
      // subtract the output from input for the fee amount.
      // (should equal feerate*tx.virtual bytes or something)
      final int coinFee = coinInput - coinOutput;
      return coinFee;
    }

    Map<String, int> _parseAsset(maybeOpRVNAssetTuplePtr, opCodes) {
// this part doesn't work, so we do it manually below
      //final assetTransferData = parseAssetTransfer(
      //    opCodes.sublist(maybeOpRVNAssetTuplePtr), x.script!);
      final assetPortion = opCodes.sublist(maybeOpRVNAssetTuplePtr)[1].item3;
      final type = assetPortion[3];
      final assetNameLength = assetPortion[4];
      if (assetPortion.length >= 5 + assetNameLength) {
        final assetName =
            utf8.decode(assetPortion.sublist(5, 5 + assetNameLength));
        if (state.security.symbol == assetName) {
          if (type == 0x6f) {
            // Ownership creation
            return {assetName: coin};
          } else if (assetPortion.length >= 13 + assetNameLength) {
            return {
              assetName: assetPortion
                  .sublist(5 + assetNameLength, 13 + assetNameLength)
                  .buffer
                  .asByteData()
                  .getUint64(0, Endian.little)
            };
          }
        }
      }
      return {'': 0};
    }

    bool getTargetAddressVerification() {
      for (final x in state.signed!.outs) {
        if (x.script != null) {
          final opCodes = getOpCodes(x.script!);
          int maybeOpRVNAssetTuplePtr = opCodes.length;
          for (int tupleCnt = 0; tupleCnt < opCodes.length; tupleCnt++) {
            if (opCodes[tupleCnt].item1 == 0xc0) {
              maybeOpRVNAssetTuplePtr = tupleCnt;
              break;
            }
          }
          final addressData = tryGuessAddressFromOpList(
              opCodes.sublist(0, maybeOpRVNAssetTuplePtr),
              Current.chainNet.constants);
          if (addressData?.address == state.address) {
            if (state.security.isCoin) {
              if (x.value == state.sats) {
                return true;
              }
            } else {
              final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
              if (nameSats[state.security.symbol] == state.sats) {
                return true;
              }
            }
          }
        }
      }
      return false;
    }

    /// coin: should be coinInput - fee - target (if any)
    /// any asset: assetInput - target
    /// also verify that every address other than the one that matches
    /// state.address is mine.
    Future<bool> getChangeAddressVerification(int coinInput, int fee) async {
      // verify all addresses
      // get change amount(s) here too
      int coinChange = 0;
      int assetChange = 0;
      for (final x in state.signed!.outs) {
        if (x.script != null) {
          final opCodes = getOpCodes(x.script!);
          int maybeOpRVNAssetTuplePtr = opCodes.length;
          for (int tupleCnt = 0; tupleCnt < opCodes.length; tupleCnt++) {
            if (opCodes[tupleCnt].item1 == 0xc0) {
              maybeOpRVNAssetTuplePtr = tupleCnt;
              break;
            }
          }
          final addressData = tryGuessAddressFromOpList(
              opCodes.sublist(0, maybeOpRVNAssetTuplePtr),
              Current.chainNet.constants);
          print(addressData);
          if (state.address == state.changeAddress) {
            coinChange += x.value ?? 0;
          } else if (addressData?.address != state.address) {
            if (addressData?.address != state.changeAddress) {
              /* where is this going? why are we sending anything to an address
              that is neither the specified changeAddress or the target address?
              so we fail here if we don't recognize the address.
              notice: if we were not to specify a changeAddress we would merely
              trust the server. this is possible because the server doesn't 
              require us to specify it, but we always do. cubit requires it.*/
              return false;
            }

            coinChange += x.value ?? 0;
            if (x.value == 0 || x.value == null) {
              final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
              assetChange += nameSats[state.security.symbol] ?? 0;
            }
          }
        }
      }
      // verify amounts
      if (state.security.isCoin) {
        if (state.address == state.changeAddress) {
          coinChange -= state.sats;
        }
        if (coinInput - fee - state.sats - coinChange != 0) {
          return false;
        }
      } else {
        if (coinInput - fee - coinChange != 0) {
          return false;
        }
        /*
        kralverde — Today at 10:48 AM
          Yeah for the vins, the tx would fail if they aren’t ours and the 
          asset/amount are pulled directly from the db
        meta stack — Today at 10:51 AM
          true I was just trying to to verify that the 
          `assetInput - assetSent == assetChange` to make sure the client is
          getting all the change they deserve back, but I can't verify that
          without determining the assetInput used, but since the server could
          lie about tx data there's no way to guarantee it.
        if (assetInput - state.sats - assetChange != 0) {
          return false;
        }
        */
      }
      // no errors found
      return true;
    }

    final coinInput = getCoinInput();
    final fee = getCoinFee(coinInput);
    return TransactionComponents(
        coinInput: coinInput,
        fee: fee,
        targetAddressAmountVerified: getTargetAddressVerification(),
        changeAddressAmountVerified:
            await getChangeAddressVerification(coinInput, fee));
  }

  /// verify fee, sending to address, and return address
  Future<Tuple2<bool, String>> verifyTransaction() async {
    final transactionComponents = await processHex();
    if (!transactionComponents.feeSanityCheck) {
      return Tuple2(false, 'fee too large');
    }
    // our estimate a of the fee should be close to the fee the server calculated,
    // which should be equal to next condition, by the way.
    if (state.fee == standardFee) {
      if (!(transactionComponents.fee <=
          state.fee.rate * state.signed!.fee(goal: state.fee) * 1.01)) {
        return Tuple2(false, 'fee does not match specified fee rate');
      }
    } else {
      // server rate is the same as our rate, but has a minimum limit of 1 kb
      // so if we specify the server rate we want to make sure it's still no
      // larger than our rate or its the minimumFee
      if (!(transactionComponents.fee <=
              state.fee.rate * state.signed!.fee(goal: state.fee) * 1.01 ||
          transactionComponents.fee <= FeeRate.minimumFee)) {
        return Tuple2(false, 'fee does not match server rate');
      }
    }
    if (!transactionComponents.targetAddressAmountVerified) {
      return Tuple2(false, 'target address or amounts invalid');
    }
    if (!transactionComponents.changeAddressAmountVerified) {
      return Tuple2(false, 'change address or amounts invalid');
    }
    //final ret = (
    //        // no transaction should cost more than 2 coins
    //        transactionComponents.feeSanityCheck &&
    //            // our estimate a of the fee should be close to the fee the server calculated,
    //            // which should be equal to next condition, by the way.
    //            (transactionComponents.fee <=
    //                    state.fee.rate *
    //                        state.signed!.fee(goal: state.fee) *
    //                        1.01 ||
    //                // or is should not be bigger than the minimum fee
    //                transactionComponents.fee <= FeeRate.minimumFee) &&
    //            transactionComponents.targetAddressAmountVerified &&
    //            transactionComponents.changeAddressAmountVerified
    //    // todo: send the value to our intended address
    //    //transactionComponents.targetAddress == state.address &&
    //    // todo: send the change back to us
    //    //transactionComponents.changeAddress == state.changeAddress //&&
    //    // todo: what about send amount?
    //    //transactionComponents.sendAmount == state.sats
    //    // todo: what about change amount?
    //    //transactionComponents.changeAmount == transactionComponents.totalOut - transactionComponents.sendAmount - transactionComponents.fee
    //    );
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
    return Tuple2(true, 'success');
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
  final int coinInput;
  final int fee;
  // assumes we're only sending to 1 address
  final bool targetAddressAmountVerified;
  // should be inputs - fee - target
  final bool changeAddressAmountVerified;
  const TransactionComponents({
    required this.coinInput,
    required this.fee,
    required this.targetAddressAmountVerified,
    required this.changeAddressAmountVerified,
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
