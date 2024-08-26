import 'dart:convert';
import 'dart:typed_data';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/concepts/send.dart';
import 'package:magic/domain/server/protocol/comm_unsigned_transaction_result_class.dart';
import 'package:magic/domain/server/wrappers/unsigned_tx_result.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/broadcast.dart';
import 'package:magic/services/calls/unsigned.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show
        ECPair,
        FeeRate,
        TransactionBuilder,
        Transaction,
        satsPerCoin,
        standardFee;
import 'package:moontree_utils/moontree_utils.dart';

part 'state.dart';

class SendCubit extends UpdatableCubit<SendState> {
  SendCubit() : super(const SendState());
  double height = 0;
  @override
  String get key => 'send';
  @override
  void reset() => emit(const SendState());
  @override
  void setState(SendState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void update({
    bool? active,
    bool? scanActive,
    String? asset,
    String? address,
    String? changeAddress,
    String? amount,
    SendRequest? sendRequest,
    UnsignedTransactionResultCalled? unsignedTransaction,
    List<Transaction>? signedTransactions,
    SendEstimate? estimate,
    List<String>? txHashes,
    bool? isSubmitting,
    SendState? prior,
    bool removeUnsignedTransaction = false,
    bool removeEstimate = false,
    String? originalAmount,
  }) {
    emit(SendState(
      active: active ?? state.active,
      scanActive: scanActive ?? state.scanActive,
      asset: asset ?? state.asset,
      address: address ?? state.address,
      changeAddress: changeAddress ?? state.changeAddress,
      amount: amount ?? state.amount,
      sendRequest: sendRequest ?? state.sendRequest,
      unsignedTransaction: unsignedTransaction ??
          (removeUnsignedTransaction ? null : state.unsignedTransaction),
      signedTransactions: signedTransactions ?? state.signedTransactions,
      estimate: estimate ?? (removeEstimate ? null : state.estimate),
      txHashes: txHashes ?? state.txHashes,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
      originalAmount: originalAmount ?? state.originalAmount,
    ));
  }

  Future<void> setUnsignedTransaction({
    bool sendAllCoinFlag = false,
    String? symbol,
    required Blockchain blockchain,
  }) async {
    update(
      isSubmitting: true,
    );
    final changeAddress =
        await cubits.receive.populateChangeAddress(blockchain);
    //cubits.receive.state.changeAddress.isEmpty ? : ;
    UnsignedTransactionResultCalled? unsigned = await UnsignedTransactionCall(
      mnemonicWallets: cubits.keys.master.mnemonicWallets,
      keypairWallets: cubits.keys.master.keypairWallets,
      symbol: symbol ?? state.asset,
      sats: sendAllCoinFlag ? -1 : state.sendRequest?.sendAmountAsSats ?? 0,
      changeAddress: changeAddress,
      address: state.address,
      memo: null, //state.memo,
      blockchain: blockchain,

      /// todo: eventually we'll make a system to have accounts serverside, and
      ///       this will be relevant. until then, keep it as a reminder
      //String? addressName,
    ).call();
    update(
      unsignedTransaction: unsigned,
      changeAddress: changeAddress,
      isSubmitting: false,
    );
  }

  Future<bool> signUnsignedTransaction() async {
    if (state.unsignedTransaction == null) {
      return false;
    }
    List<Transaction> txs = [];
    for (final UnsignedTransactionResult unsigned
        in state.unsignedTransaction!.unsignedTransactionResults) {
      print('----');
      print('vinAssets: ${unsigned.vinAssets}');
      print('vinAmounts: ${unsigned.vinAmounts}');
      print('targetFee: ${unsigned.targetFee}');
      print('changeSource: ${unsigned.changeSource}');
      print('vinPrivateKeySource: ${unsigned.vinPrivateKeySource}');
      print('----------------');

      final txb = TransactionBuilder.fromRawInfo(
          unsigned.rawHex,
          unsigned.vinScriptOverride.map((String? e) => e?.hexBytes),
          unsigned.vinLockingScriptType.map((e) =>
              e == -1 ? null : ['pubkeyhash', 'scripthash', 'pubkey'][e]),
          state.unsignedTransaction!.security.blockchain.network);
      // this map reduces the time to sign large tx in half (for mining wallets)
      Map<String, ECPair?> keyPairByPath = {};
      ECPair? keyPair;
      final List<String> walletRoots = state.unsignedTransaction!.roots;
      for (final Tuple2<int, String> e
          in unsigned.vinPrivateKeySource.enumeratedTuple<String>()) {
        final vinIndex = e.item1;
        final privateKeySource = e.item2;
        if (privateKeySource.contains(':')) {
          print('privateKeySource: $privateKeySource');
          print('vinIndex: $vinIndex');
          final walletPubKeyAndDerivationIndex = privateKeySource.split(':');
          final String walletRoot = walletPubKeyAndDerivationIndex[0];
          final int derivationIndex =
              int.parse(walletPubKeyAndDerivationIndex[1]);
          print('walletRoot: $walletRoot');
          print('derivationIndex: $derivationIndex');

          /*
          I/flutter ( 5038): privateKeySource: xpub6EPLto1UvaKqiJSsBntBY6F4yb8Z68u9ZA6v2Jd37pTto3HzRWrrELDR6zVUXQhr3AvVwDq3CnqiQzod1cgpyHrKD3CbUBotsoBfn5bnKCg:21
          I/flutter ( 5038): vinIndex: 0
          I/flutter ( 5038): walletRoot: xpub6EPLto1UvaKqiJSsBntBY6F4yb8Z68u9ZA6v2Jd37pTto3HzRWrrELDR6zVUXQhr3AvVwDq3CnqiQzod1cgpyHrKD3CbUBotsoBfn5bnKCg
          I/flutter ( 5038): derivationIndex: 21
          I/flutter ( 5038): p: m/44'/175'/0'/1/21

          vinIndex? how is it used?
          */

          final wallet = cubits.keys.master.mnemonicWallets.firstWhere(
              (MnemonicWallet wallet) => wallet
                  .roots(state.unsignedTransaction!.security.blockchain)
                  .contains(walletRoot),
              orElse: () =>
                  throw Exception('Wallet not found for root: $walletRoot'));

          print(
              'wallet: $wallet, wallet.roots: ${wallet.roots(state.unsignedTransaction!.security.blockchain)}');
          final Exposure exposure = walletRoot ==
                  wallet.root(state.unsignedTransaction!.security.blockchain,
                      Exposure.external)
              ? Exposure.external
              : Exposure.internal;
          print('exposure: $exposure');
          keyPairByPath['${exposure.index}/$derivationIndex'] ??= wallet
              .seedWallet(state.unsignedTransaction!.security.blockchain)
              .subwallet(
                hdIndex: derivationIndex,
                exposure: exposure,
              )
              .keyPair;
          print(
              'address: ${wallet.seedWallet(state.unsignedTransaction!.security.blockchain).subwallet(
                    hdIndex: derivationIndex,
                    exposure: exposure,
                  ).address}');
          /*
          well there you go EPTCNCFjuSP7pJLVYsF6hD64dzXFsMuo3a has nothing in it.
          either the server is giving us bad data or we are not deriving the correct keypair.
          */
          keyPair = keyPairByPath['${exposure.index}/$derivationIndex'];
          // not sure this works right - what if we have multiple KeypairWallets?
          // I don't think this necessarily selects the correct one. perhaps this
          // never happens since e.item2.contains(':') is probably indicitive of
          // MnemonicWallet.
          //if (keyPair == null) {
          //  keyPairByPath[
          //        '${exposure.index}/${int.parse(walletPubKeyAndDerivationIndex[1])}'] ??=
          //        cubits.keys.master.keypairWallets
          //            .map((KeypairWallet e) => e.wallet(state.unsignedTransaction!.blockchain).keyPair).firstOrNull;
          //  keyPair = keyPairByPath[
          //        '${exposure.index}/${int.parse(walletPubKeyAndDerivationIndex[1])}'];
          //}
        } else {
          // case for SingleWallet
          // what do we have to match on? never tested, old design had Current.wallet concept, we don't.
          //if (e.item2 !=
          //    (Current.wallet as SingleWallet).addresses.first.h160AsString) {
          //  throw Exception(
          //      ("Single wallet signing erorr: wallet doens't match h160 returned from server\n"
          //          "h160: ${e.item2}"
          //          "local: ${(Current.wallet as SingleWallet).addresses.first.h160AsString}"));
          //}
          //keyPair ??= await services.wallet.getAddressKeypair(
          //    (Current.wallet as SingleWallet).addresses.first);
          // this should work if they only have one keypair wallet:
          keyPair = cubits.keys.master.keypairWallets
              //.where((KeypairWallet wallet) => wallet
              //  .wallet(state.unsignedTransaction!.security.blockchain)
              //  .address == unsigned.vinAddresses[vinIndex])
              .map((KeypairWallet e) => e
                  .wallet(state.unsignedTransaction!.security.blockchain)
                  .keyPair)
              .firstOrNull;
        }
        txb.signRaw(
          vin: vinIndex,
          keyPair: keyPair!,
          // note for swaps: hashType: SIGHASH_SINGLE | SIGHASH_ANYONECANPAY,
          hashType: null,
          prevOutScriptOverride: unsigned.vinScriptOverride[vinIndex]?.hexBytes,
          asset: unsigned.vinAssets[vinIndex],
          assetAmount: unsigned.vinAmounts[vinIndex],
          assetLiteral: state
              .unsignedTransaction!.security.blockchain.chaindata.assetLiteral,
        );
      }
      final tx = txb.build();
      txs.add(tx);
    }
    update(signedTransactions: txs);
    // compare this against parsed fee amount to verify fee.
    if (txs.isEmpty) {
      return false;
    }
    return true;
  }

  /// parse transaction to verify elements within
  Future<TransactionComponents> processHex(
    int index,
    Transaction signed,
  ) async {
    /// sum the vinAmounts that are evr
    int getCoinInput() => [
          for (final x in IterableZip([
            state.unsignedTransaction!.unsignedTransactionResults[index]
                .vinAssets,
            state.unsignedTransaction!.unsignedTransactionResults[index]
                .vinAmounts,
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
        if (state.unsignedTransaction!.security.symbol == assetName) {
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

    bool getTargetAddressVerification(Transaction signed, int fee) {
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
              state.unsignedTransaction!.security.blockchain.constants);
          if (addressData?.address == state.address) {
            if (state.signedTransactions.length == 1) {
              if (state.unsignedTransaction!.security.isCoin) {
                if ((!state.sendRequest!.sendAll &&
                        x.value == state.sendRequest!.sendAmountAsSats) ||
                    (state.sendRequest!.sendAll &&
                        x.value == state.sendRequest!.sendAmountAsSats - fee)) {
                  return true;
                }
              } else {
                final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
                if (nameSats[state.unsignedTransaction!.security.symbol] ==
                    state.unsignedTransaction!.sats) {
                  return true;
                }
              }
            }
          }
        }
      }
      if (state.signedTransactions.length > 1) {
        return true;
      }
      return false;
    }

    bool getTargetAddressVerificationForAll(int fee) {
      // do this once on the last tx
      if (index == state.signedTransactions.length - 1) {
        return [
          for (final s in state.signedTransactions)
            getTargetAddressVerification(s, fee)
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
      for (final UnsignedTransactionResult unsigned
          in state.unsignedTransaction!.unsignedTransactionResults) {
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
                state.unsignedTransaction!.security.blockchain
                    .addressFromH160String(cs)) {
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
              state.unsignedTransaction!.security.blockchain.constants);
          if (state.address == state.changeAddress) {
            coinChange += x.value ?? 0;
          } else if (addressData?.address != state.address) {
            coinChange += x.value ?? 0;
            // //if (x.value == 0 || x.value == null) {
            // //  final nameSats = _parseAsset(maybeOpRVNAssetTuplePtr, opCodes);
            // //  assetChange += nameSats[state.security.symbol] ?? 0;
            // //}
          }
        }
      }
      if (state.signedTransactions.length == 1) {
        // verify amounts
        if (state.unsignedTransaction!.security.isCoin) {
          if (state.address == state.changeAddress) {
            coinChange -= state.sendRequest!.sendAmountAsSats;
          }
          if (state.sendRequest!.sendAll) {
            if (coinChange > 0) {
              return false;
            }
          } else {
            if (coinInput -
                    fee -
                    state.sendRequest!.sendAmountAsSats -
                    coinChange !=
                0) {
              return false;
            }
          }
        } else {
          if (coinInput - fee - coinChange != 0) {
            return false;
          }
          //kralverde — Today at 10:48 AM
          //  Yeah for the vins, the tx would fail if they aren't ours and the
          //  asset/amount are pulled directly from the db
          //meta stack — Today at 10:51 AM
          //  true I was just trying to to verify that the
          //  `assetInput - assetSent == assetChange` to make sure the client is
          //  getting all the change they deserve back, but I can't verify that
          //  without determining the assetInput used, but since the server could
          //  lie about tx data there's no way to guarantee it.
          //if (assetInput - state.sats - assetChange != 0) {
          //  return false;
          //}
        }
      }
      // no errors found
      return true;
    }

    Future<bool> getChangeAddressVerificationForAll() async {
      // do this once on the last tx
      if (index == state.signedTransactions.length - 1) {
        return [
          for (final _ in state.signedTransactions)
            await getChangeAddressVerification(0, 0)
        ].every((i) => i);
      }
      return true;
    }

    if (state.sendRequest == null || state.unsignedTransaction == null) {
      return const TransactionComponents(
          coinInput: 0,
          fee: 0,
          targetAddressAmountVerified: false,
          changeAddressAmountVerified: false);
    }
    final coinInput = getCoinInput();
    final fee = getCoinFee(coinInput);
    final targetAddressVerified = state.signedTransactions.length == 1
        ? getTargetAddressVerification(signed, fee)
        : getTargetAddressVerificationForAll(fee);
    final changeAddressVerified = state.signedTransactions.length == 1
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
    for (final Tuple2<int, Transaction> indexSigned
        in (state.signedTransactions).enumeratedTuple<Transaction>()) {
      final transactionComponents =
          await processHex(indexSigned.item1, indexSigned.item2);
      if (!transactionComponents.feeSanityCheck) {
        return const Tuple2(false, 'fee too large');
      }
      // our estimate a of the fee should be close to the fee the server calculated,
      // which should be equal to next condition, by the way.
      if (state.sendRequest!.feeRate == standardFee) {
        if (!(transactionComponents.fee <=
            state.sendRequest!.feeRate.rate *
                indexSigned.item2.fee(goal: state.sendRequest!.feeRate) *
                1.01)) {
          return const Tuple2(false, 'fee does not match specified fee rate');
        }
      } else {
        // server rate is the same as our rate, but has a minimum limit of 1 kb
        // so if we specify the server rate we want to make sure it's still no
        // larger than our rate or its the minimumFee
        if (!(transactionComponents.fee <=
                state.sendRequest!.feeRate.rate *
                    indexSigned.item2.fee(goal: state.sendRequest!.feeRate) *
                    1.01 ||
            transactionComponents.fee <= FeeRate.minimumFee)) {
          return const Tuple2(false, 'fee does not match server rate');
        }
      }
      if (!transactionComponents.targetAddressAmountVerified) {
        return const Tuple2(false, 'target address or amounts invalid');
      }
      if (!transactionComponents.changeAddressAmountVerified) {
        return const Tuple2(false, 'change address or amounts invalid');
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
    if (state.unsignedTransaction != null) {
      update(
        estimate: SendEstimate(
          amount: state.sendRequest!.sendAmountAsSats,
          sendAll: state.sendRequest!.sendAll,
          fees: fees,
          security: state.unsignedTransaction!.security,
          memo: state.unsignedTransaction!.memo,
          creation: false,
        ),
      );
      return const Tuple2(true, 'success');
    }
    return const Tuple2(false, 'failure');
  }

  /// actually commit transaction
  Future<void> broadcast({String? amount, String? symbol}) async {
    if (state.signedTransactions.isEmpty) {
      print('transaction not signed yet');
      return;
    }
    for (final Transaction signed in state.signedTransactions) {
      print('broadcasting ${signed.toHex()}');

      /// should we use a repository for this? why? myabe for validation purposes?
      /// and for saving the note in success case? we'd still do the rest here...
      /// todo: do repo pattern I guess..
      final broadcastResult = (await BroadcastTransactionCall(
        rawTransactionHex: signed.toHex(),
        blockchain: state.unsignedTransaction!.security.blockchain,
      )());

      // todo: should we do more validation on the txHash?
      if (broadcastResult.value != null && broadcastResult.error == null) {
        update(txHashes: [...state.txHashes, broadcastResult.value!]);
        print(broadcastResult);
        // todo: save note by this txHash here
        // should this be in a repo?
        //pros.notes.save(
        //    Note(note: state.note, transactionId: broadcastResult.value!));
        Future.delayed(const Duration(seconds: 2))
            .then((_) => cubits.toast.flash(
                    msg: ToastMessage(
                  title: 'Sent:',
                  text: amount != null && symbol != null
                      ? '$amount $symbol'
                      : amount ?? symbol ?? 'Successful',
                  force: true,
                )));
      } else {
        Future.delayed(const Duration(seconds: 2))
            .then((_) => cubits.toast.flash(
                    msg: const ToastMessage(
                  title: 'Failed',
                  text: 'Unable to send, try again later',
                  //copy: broadcastResult.error!
                )));
      }
    }
  }

  /**from v2



   */
}
