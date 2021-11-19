import 'dart:math';

import 'package:raven/raven.dart';
import 'package:ravencoin/ravencoin.dart' as ravencoin;
import 'package:tuple/tuple.dart';

import 'transaction/fee.dart';
import 'transaction/sign.dart';

const ESTIMATED_OUTPUT_FEE = 0 /* why 34? */;
const ESTIMATED_FEE_PER_INPUT = 0 /* why 51? */;

class SendEstimate {
  int amount;
  int fees;
  List<Vout> utxos;

  @override
  String toString() => 'amount: $amount, fees: $fees, utxos: $utxos';

  int get total => amount + fees;
  int get utxoTotal =>
      utxos.fold(0, (int total, vout) => total + vout.rvnValue);

  int get changeDue => utxoTotal - total;

  SendEstimate(
    this.amount, {
    this.fees = ESTIMATED_OUTPUT_FEE + ESTIMATED_FEE_PER_INPUT,
    List<Vout>? utxos,
  }) : utxos = utxos ?? [];

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  void setFees(int fees_) => fees = fees_;
  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
  void setAmount(int amount_) => amount = amount_;
}

class MakeTransactionService {
  /// gets inputs, calculates fee, returns change
  //
  // EXAMPLE of recursive function
  //
  // Let's say we start with the following UTXOs available:
  // utxos 60
  //       50
  //       9
  //
  // amount: 45
  // estimate fee: 4
  //
  // utxos: [50]
  // changeDue: 50 - 49 = 1
  // setFees(25) <-- due to signing each input, fees grow
  // updatedChangeDue: 50 - 70 = -20 : insufficient! -> iterate again, with updatedEstimate
  //   updatedEstimate: amount = 45, fees = 25 -> iterate again
  //
  // utxos: [60, 50]
  // changeDue: 110 - 70 = 40
  // setFees(35) <-- we have more inputs this time, so fees grow
  // updatedChangeDue: 110 - (45 + 35) = 30 : sufficient! BUT changeDue is WRONG
  //   updatedEstimate: amount = 45, fees = 35 -> iterate again
  //
  // utxos: [60, 50]
  // changeDue: 110 - (45 + 35) = 30
  // setFees(35) <-- fee is the same because have the same number of inputs & outputs as previous iteration
  // updatedChangeDue: 110 - (45 + 35) = 30 : sufficient! and changeDue is RIGHT
  //   -> DONE with result
  Tuple2<ravencoin.Transaction, SendEstimate> buildTransaction(
    String toAddress,
    SendEstimate estimate, {
    Account? account,
    Wallet? wallet,
    TxGoal? goal,
  }) {
    var useWallet = shouldUseWallet(account: account, wallet: wallet);

    var txb = ravencoin.TransactionBuilder(
        network: useWallet ? wallet!.account!.network : account!.network);

    // Direct the transaction to send value to the desired address
    // measure fee?
    txb.addOutput(toAddress, estimate.amount);

    // From the available wallets and UTXOs within our account,
    // find sufficient value to send to the address above
    // result = addInputs(txb, account, SendEstimate(sendAmount));
    // send
    var utxos = useWallet
        ? services.balance.collectUTXOsWallet(wallet!, amount: estimate.total)
        : services.balance.collectUTXOs(account!, amount: estimate.total);

    for (var utxo in utxos) {
      txb.addInput(utxo.txId, utxo.position);
    }

    var updatedEstimate = SendEstimate.copy(estimate)..setUTXOs(utxos);

    // Calculate change due, and return it to a wallet we control
    var returnAddress = useWallet
        ? services.wallet.getChangeWallet(wallet!).address
        : services.account.getChangeWallet(account!).address;
    var preliminaryChangeDue = updatedEstimate.changeDue;
    txb.addOutput(returnAddress, preliminaryChangeDue);

    // Authorize the release of value by signing the transaction UTXOs
    txb.signEachInput(utxos);

    var tx = txb.build();

    updatedEstimate.setFees(max(tx.fee(goal), estimate.fees));
    if (updatedEstimate.changeDue >= 0 &&
        updatedEstimate.changeDue == preliminaryChangeDue) {
      // success!
      return Tuple2(tx, updatedEstimate);
    } else {
      // try again
      return buildTransaction(
        toAddress,
        updatedEstimate,
        goal: goal,
        account: account,
        wallet: wallet,
      );
    }
  }

  Tuple2<ravencoin.Transaction, SendEstimate> buildTransactionSendAll(
    String toAddress,
    SendEstimate estimate, {
    Account? account,
    Wallet? wallet,
    TxGoal? goal,
    Set<int>? previousFees,
  }) {
    previousFees = previousFees ?? {};
    var useWallet = shouldUseWallet(account: account, wallet: wallet);
    var txb = ravencoin.TransactionBuilder(
        network: useWallet ? wallet!.account!.network : account!.network);
    var utxos = useWallet
        ? services.balance.sortedUnspentsWallets(wallet!)
        : services.balance.sortedUnspents(account!);
    var total = 0;
    for (var utxo in utxos) {
      txb.addInput(utxo.txId, utxo.position);
      total = total + utxo.rvnValue;
    }
    var updatedEstimate = SendEstimate.copy(estimate)..setUTXOs(utxos);
    txb.addOutput(toAddress, estimate.amount);
    txb.signEachInput(utxos);
    var tx = txb.build();
    var fees = tx.fee(goal);
    updatedEstimate.setFees(tx.fee(goal));
    updatedEstimate.setAmount(total - fees);
    if (previousFees.contains(fees)) {
      return Tuple2(tx, updatedEstimate);
    } else {
      return buildTransactionSendAll(
        toAddress,
        updatedEstimate,
        goal: goal,
        account: account,
        wallet: wallet,
        previousFees: {...previousFees, fees},
      );
    }
  }

  bool shouldUseWallet({Account? account, Wallet? wallet}) {
    if (wallet != null) {
      return true;
    } else if (account != null) {
      return false;
    } else {
      throw OneOfMultipleMissing('account or wallet required');
    }
  }
}


/*
E/flutter ( 6908): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: JSON-RPC error 1: the transaction was rejected by network rules.
E/flutter ( 6908): 
E/flutter ( 6908): 66: min relay fee not met
E/flutter ( 6908): [010000000272bc5e0102534d6c8637e2c577329858e13f8dcdd045249bbcc2f440d6a5e29f010000006a4730440220681eec03fdcc49a16017f7750ad6da3764c52f17acfbd3731f1573630f386dc9022014185980414f7efbfbdaf5b92425082df41893e15c8fa15fd221d31ccad33e5d012102f2954600d47cfd12796f8023eab6edf2f9d718bfe3b47ed21a8c7b7818f9cb52ffffffffdc81f1a15eed7d7ececc6d422b515479319b47747dd5c1cdd29cf882e8130be6000000006a47304402206460fb8c1d0bb39019f7ade74cec04ddc85bceebd548a1f5f19ee591a3944d8502202085955cf61e34af5c5a9a2060c2748c914a02516f68f5b9c3697fbd3a51e4a601210333b0947d853fd6fb9a6903c14eaeafc19e91f6909c38da7b807f51b6a842f6a7ffffffff014cd5440a360400001976a9146cfc136aeebb9eef937125330547ef94795c359f88ac00000000]
E/flutter ( 6908): package:json_rpc_2/src/client.dart 121:62                              Client.sendRequest
E/flutter ( 6908): package:json_rpc_2/src/peer.dart 98:15                                 Peer.sendRequest
E/flutter ( 6908): package:raven_electrum_client/client/base_client.dart 52:23            BaseClient.request
E/flutter ( 6908): package:raven_electrum_client/methods/transaction/broadcast.dart 4:68  BroadcastTransactionMethod.broadcastTransaction        
E/flutter ( 6908): package:raven/services/client.dart 132:47                              ApiService.sendTransaction
E/flutter ( 6908): package:raven_mobile/pages/transaction/send.dart 640:44                _SendState.attemptSend
E/flutter ( 6908): package:raven_mobile/pages/transaction/send.dart 603:54                _SendState.confirmMessage.<fn>.<fn>
E/flutter ( 6908): package:raven_mobile/pages/transaction/send.dart 603:36                _SendState.confirmMessage.<fn>.<fn>
E/flutter ( 6908): package:flutter/src/material/ink_well.dart 989:21                      _InkResponseState._handleTap
E/flutter ( 6908): package:flutter/src/gestures/recognizer.dart 198:24                    GestureRecognizer.invokeCallback
E/flutter ( 6908): package:flutter/src/gestures/tap.dart 608:11                           TapGestureRecognizer.handleTapUp
E/flutter ( 6908): package:flutter/src/gestures/tap.dart 296:5                            BaseTapGestureRecognizer._checkUp
E/flutter ( 6908): package:flutter/src/gestures/tap.dart 230:7                            BaseTapGestureRecognizer.handlePrimaryPointer
E/flutter ( 6908): package:flutter/src/gestures/recognizer.dart 563:9                     PrimaryPointerGestureRecognizer.handleEvent
E/flutter ( 6908): package:flutter/src/gestures/pointer_router.dart 94:12                 PointerRouter._dispatch
E/flutter ( 6908): package:flutter/src/gestures/pointer_router.dart 139:9                 PointerRouter._dispatchEventToRoutes.<fn>
E/flutter ( 6908): dart:collection-patch/compact_hash.dart 525:8                          _LinkedHashMapMixin.forEach
E/flutter ( 6908): package:flutter/src/gestures/pointer_router.dart 137:18                PointerRouter._dispatchEventToRoutes
E/flutter ( 6908): package:flutter/src/gestures/pointer_router.dart 123:7                 PointerRouter.route
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 440:19                       GestureBinding.handleEvent
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 420:22                       GestureBinding.dispatchEvent
E/flutter ( 6908): package:flutter/src/rendering/binding.dart 278:11                      RendererBinding.dispatchEvent
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 374:7                        GestureBinding._handlePointerEventImmediately
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 338:5                        GestureBinding.handlePointerEvent
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 296:7                        GestureBinding._flushPointerEventQueue
E/flutter ( 6908): package:flutter/src/gestures/binding.dart 279:7                        GestureBinding._handlePointerDataPacket
E/flutter ( 6908): dart:async/zone.dart 1444:13                                           _rootRunUnary
E/flutter ( 6908): dart:async/zone.dart 1335:19                                           _CustomZone.runUnary
E/flutter ( 6908): dart:async/zone.dart 1244:7                                            _CustomZone.runUnaryGuarded
E/flutter ( 6908): dart:ui/hooks.dart 169:10                                              _invoke1
E/flutter ( 6908): dart:ui/platform_dispatcher.dart 293:7                                 PlatformDispatcher._dispatchPointerDataPacket
E/flutter ( 6908): dart:ui/hooks.dart 88:31                                               _dispatchPointerDataPacket
E/flutter ( 6908):
V/Datadog ( 6908): Batch [1912 bytes] sent successfully (RumOkHttpUploader).

*/