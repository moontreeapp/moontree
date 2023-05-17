import 'dart:convert';
import 'dart:typed_data';
import 'package:client_front/application/utilities.dart';
import 'package:tuple/tuple.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:collection/src/iterable_zip.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
//    show StringBytesExtension, EnumeratedIteratable;
import 'package:wallet_utils/wallet_utils.dart'
    show ECPair, FeeRate, TransactionBuilder, satsPerCoin, standardFee;
import 'package:wallet_utils/src/transaction.dart' as wutx;
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:client_front/infrastructure/repos/receive.dart';
import 'package:client_front/infrastructure/repos/unsigned.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
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
    String? changeAddress,
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
        changeAddress: changeAddress ?? state.changeAddress,
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
  }) async {
    update(isSubmitting: true);
    final changeAddress =
        (await ReceiveRepo(wallet: wallet, change: true).fetch())
            .address(chain, net);
    List<UnsignedTransactionResult> unsigned = await UnsignedTransactionRepo(
      wallet: wallet,
      symbol: symbol,
      security: Security(
          symbol: symbol,
          securityType: SecurityType.asset,
          chain: chain,
          net: net),
      feeRate: state.feeRate == standardFee ? state.feeRate : null,
      sats: state.assetCreationFeeSats,
      changeAddress: changeAddress,
      address: changeAddress,
      memo: state.memo,
      chain: chain,
      net: net,
    ).fetch(only: true);
    update(
      unsigned: unsigned,
      changeAddress: changeAddress,
      isSubmitting: false,
    );
  }

  /// supports verifyTransaction
  /// /// parse transaction to verify elements within
  Future<TransactionComponents> processHex(
    int index,
    wutx.Transaction signed,
  ) async {
    /// sum the vinAmounts that are evr
    int getCoinInput() => [
          for (final x in IterableZip([
            state.unsigned![index].vinAssets,
            state.unsigned![index].vinAmounts,
          ]))
            x[0] == null ? x[1] : 0
        ].sum() as int;

    int getCoinFee(int coinInput) {
      //{code: -26, message: 16: mandatory-script-verify-flag-failed (Signature must be zero for failed CHECK(MULTI)SIG operation)}
      // parsed transaction vouts that are evr (txb.vouts.sum that are evr)
      // technically unnecessary to filer since assets will always have 0 value
      final int coinOutput = signed.outs
          .where((e) => e.value != null && e.value! > 0) // filter to evr
          .map((e) => e.value)
          .sum() as int;
      // subtract the output from input for the fee amount.
      // (should equal feerate*tx.virtual bytes or something)
      final int coinFee = coinInput - coinOutput;
      return coinFee;
    }

    /// verify the asset is getting sent to an address we own
    bool getTargetAddressVerification(wutx.Transaction signed, int fee) {
      for (final x in signed.outs) {
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

          //if (addressData?.address == state.address) {
          //  if (state.signed!.length == 1) {
          //    final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
          //    if (nameSats[Current.chainNet.symbol] == state.sats) {
          //      return true;
          //    }
          //  }
          //}
          if (addressData?.address == state.changeAddress) {
            return true;
          }
        }
      }
      if (state.signed!.length > 1) {
        return true;
      }
      return false;
    }

    bool getTargetAddressVerificationForAll(int fee) {
      // do this once on the last tx
      if (index == state.signed!.length - 1) {
        return [
          for (final s in state.signed!) getTargetAddressVerification(s, fee)
        ].every((i) => i);
      }
      return true;
    }

    /// coin: should be coinInput - fee - target (if any)
    /// any asset: assetInput - target
    /// also verify that every address other than the one that matches
    /// state.address is mine.
    Future<bool> getChangeAddressVerification(int coinInput, int fee) async {
      // verify all addresses
      // get change amount(s) here too
      for (final UnsignedTransactionResult unsigned in state.unsigned ?? []) {
        for (final cs in unsigned.changeSource) {
          /* kralverde -
          Just fyi it can also be wallet_key:index just like the vin source
          meta stack -
          the changeSource?
          kralverde - 
          Yeah, if you were to put in a change wallet for instance */
          if (cs != null && !cs.contains(':')) {
            //print(state.changeAddress);
            //print(Current.chainNet.addressFromH160String(cs));
            //print(h160ToAddress(
            //    cs.hexBytes, Current.chainNet.chaindata.p2pkhPrefix));
            if (state.changeAddress !=
                Current.chainNet.addressFromH160String(cs)) {
              /* where is this going? why are we sending anything to an address
              that is neither the specified changeAddress or the target address?
              so we fail here if we don't recognize the address.
              notice: if we were not to specify a changeAddress we would merely
              trust the server. this is possible because the server doesn't 
              require us to specify it, but we always do. cubit requires it.*/
              return false;
            }
          }
        }
      }
      int coinChange = 0;
      // //int assetChange = 0;
      for (final x in signed.outs) {
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
          if (addressData?.address == state.changeAddress) {
            coinChange += x.value ?? 0;
            // //if (x.value == 0 || x.value == null) {
            // //  final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
            // //  assetChange += nameSats[state.security.symbol] ?? 0;
            // //}
          } else {
            // why doesn't the server send back to the changeAddress we specified?
            return false;
          }
        }
      }
      if (state.signed!.length == 1) {
        // verify amounts
        if (coinInput - fee - coinChange != 0) {
          return false;
        }
      }
      // no errors found
      return true;
    }

    Future<bool> getChangeAddressVerificationForAll() async {
      // do this once on the last tx
      if (index == state.signed!.length - 1) {
        return [
          for (final _ in state.signed!)
            await getChangeAddressVerification(0, 0)
        ].every((i) => i);
      }
      return true;
    }

    final coinInput = getCoinInput();
    final fee = getCoinFee(coinInput);
    final targetAddressVerified = state.signed!.length == 1
        ? getTargetAddressVerification(signed, fee)
        : getTargetAddressVerificationForAll(fee);
    final changeAddressVerified = state.signed!.length == 1
        ? await getChangeAddressVerification(coinInput, fee)
        : await getChangeAddressVerificationForAll();
    return TransactionComponents(
        coinInput: coinInput,
        fee: fee,
        targetAddressAmountVerified: targetAddressVerified,
        changeAddressAmountVerified: changeAddressVerified);
  }

  /// verify fee, sending to address, and return address
  Future<Tuple2<bool, String>> verifyTransaction() async {
    int fees = 0;
    for (final Tuple2<int, wutx.Transaction> indexSigned
        in (state.signed ?? []).enumeratedTuple<wutx.Transaction>()) {
      final transactionComponents =
          await processHex(indexSigned.item1, indexSigned.item2);
      if (!transactionComponents.feeSanityCheck) {
        return Tuple2(false, 'fee too large');
      }
      // our estimate a of the fee should be close to the fee the server calculated,
      // which should be equal to next condition, by the way.
      if (state.fee == standardFee) {
        if (!(transactionComponents.fee <=
            state.feeRate!.rate *
                indexSigned.item2.fee(goal: state.feeRate) *
                1.01)) {
          return Tuple2(false, 'fee does not match specified fee rate');
        }
      } else {
        // server rate is the same as our rate, but has a minimum limit of 1 kb
        // so if we specify the server rate we want to make sure it's still no
        // larger than our rate or its the minimumFee
        if (!(transactionComponents.fee <=
                state.feeRate!.rate *
                    indexSigned.item2.fee(goal: state.feeRate) *
                    1.01 ||
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
      fees += transactionComponents.fee;
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
    update(fee: fees);
    return Tuple2(true, 'success');
  }

  /// convert to TransactionBuilder object, inspect
  Future<bool> sign() async {
    List<wutx.Transaction> txs = [];
    for (final UnsignedTransactionResult unsigned in state.unsigned ?? []) {
      final txb = TransactionBuilder.fromRawInfo(
          unsigned.rawHex,
          unsigned.vinScriptOverride.map((String? e) => e?.hexBytes),
          unsigned.vinLockingScriptType.map((e) =>
              e == -1 ? null : ['pubkeyhash', 'scripthash', 'pubkey'][e]),
          pros.settings.chainNet.network);
      // this map reduces the time to sign large tx in half (for mining wallets)
      Map<String, ECPair?> keyPairByPath = {};
      ECPair? keyPair;
      final List<String> walletRoots =
          await (Current.wallet as LeaderWallet).roots;
      for (final Tuple2<int, String> e
          in unsigned.vinPrivateKeySource.enumeratedTuple<String>()) {
        if (e.item2.contains(':')) {
          final walletPubKeyAndDerivationIndex = e.item2.split(':');
          // todo Current.wallet must be LeaderWallet, if not err?
          final NodeExposure nodeExposure =
              walletPubKeyAndDerivationIndex[0] == walletRoots[0]
                  ? NodeExposure.external
                  : NodeExposure.internal;
          keyPairByPath[
                  '${nodeExposure.index}/${int.parse(walletPubKeyAndDerivationIndex[1])}'] ??=
              await services.wallet.getAddressKeypair(
                  await services.wallet.leader.deriveAddressByIndex(
            wallet: Current.wallet as LeaderWallet,
            exposure: nodeExposure,
            hdIndex: int.parse(walletPubKeyAndDerivationIndex[1]),
            chain: pros.settings.chain,
            net: pros.settings.net,
          ));
          keyPair = keyPairByPath[
              '${nodeExposure.index}/${int.parse(walletPubKeyAndDerivationIndex[1])}'];
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
          keyPair ??= await services.wallet.getAddressKeypair(
              (Current.wallet as SingleWallet).addresses.first);
        }
        txb.signRaw(
          vin: e.item1,
          keyPair: keyPair!,
          // note for swaps: hashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
          hashType: null,
          prevOutScriptOverride: unsigned.vinScriptOverride[e.item1]?.hexBytes,
          asset: unsigned.vinAssets[e.item1],
          assetAmount: unsigned.vinAmounts[e.item1],
          assetLiteral: Current.chainNet.chaindata.assetLiteral,
        );
      }
      final tx = txb.build();
      txs.add(tx);
    }
    update(signed: txs);
    // compare this against parsed fee amount to verify fee.
    return false;
  }

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
