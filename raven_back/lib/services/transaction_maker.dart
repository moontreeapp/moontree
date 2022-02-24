import 'dart:math';

import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:tuple/tuple.dart';

import 'transaction/fee.dart';
import 'transaction/sign.dart';

const ESTIMATED_OUTPUT_FEE = 0 /* why 34? */;
const ESTIMATED_FEE_PER_INPUT = 0 /* why 51? */;

class NFTCreateRequest {
  late String name;
  late String ipfs;
  late String parent; // you have to use the wallet that holds the prent

  NFTCreateRequest({
    required this.name,
    required this.ipfs,
    required this.parent,
  });
}

class ChannelCreateRequest {
  late String name;
  late String ipfs;
  late String parent; // you have to use the wallet that holds the prent

  ChannelCreateRequest({
    required this.name,
    required this.ipfs,
    required this.parent,
  });
}

class QualifierCreateRequest {
  late String name;
  late String ipfs;
  late String quantity;
  late String parent; // you have to use the wallet that holds the prent

  QualifierCreateRequest({
    required this.name,
    required this.quantity,
    required this.ipfs,
    required this.parent,
  });
}

class MainCreateRequest {
  late String name;
  late String ipfs;
  late int quantity;
  late int decimals;
  late bool reissuable;
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

  MainCreateRequest({
    required this.name,
    required this.ipfs,
    required this.quantity,
    required this.decimals,
    required this.reissuable,
    this.parent,
  });
}

class RestrictedCreateRequest {
  late String name;
  late String ipfs;
  late int quantity;
  late int decimals;
  late String verifier;
  late bool reissuable;

  RestrictedCreateRequest({
    required this.name,
    required this.ipfs,
    required this.quantity,
    required this.decimals,
    required this.verifier,
    required this.reissuable,
  });
}

class GenericCreateRequest {
  late String name;
  late String ipfs;
  late int? quantity;
  late int? decimals;
  late String? verifier;
  late bool? reissuable;
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

  GenericCreateRequest({
    required this.name,
    required this.ipfs,
    this.quantity,
    this.decimals,
    this.verifier,
    this.reissuable,
    this.parent,
  });
}

class SendRequest {
  late bool sendAll;
  late String sendAddress;
  late double holding;
  late String visibleAmount;
  late int sendAmountAsSats;
  late TxGoal feeGoal;
  late Wallet wallet;

  SendRequest({
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    required this.feeGoal,
    required this.wallet,
  });
}

class SendEstimate {
  int amount;
  int fees;
  List<Vout> utxos;
  Security? security;

  @override
  String toString() => 'amount: $amount, fees: $fees, utxos: $utxos';

  int get total => amount + fees;
  int get utxoTotal => utxos.fold(
      0, (int total, vout) => total + vout.securityValue(security: security));

  int get changeDue => utxoTotal - total;

  SendEstimate(
    this.amount, {
    this.fees = ESTIMATED_OUTPUT_FEE + ESTIMATED_FEE_PER_INPUT,
    List<Vout>? utxos,
    this.security,
  }) : utxos = utxos ?? [];

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  void setFees(int fees_) => fees = fees_;
  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
  void setAmount(int amount_) => amount = amount_;
}

class TransactionMaker {
  Tuple2<ravencoin.Transaction, SendEstimate> transactionBy(
    SendRequest sendRequest,
  ) {
    var tuple;
    tuple = (sendRequest.sendAll ||
            double.parse(sendRequest.visibleAmount) == sendRequest.holding)
        ? transactionSendAll(
            sendRequest.sendAddress,
            SendEstimate(sendRequest.sendAmountAsSats),
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          )
        : transaction(
            sendRequest.sendAddress,
            SendEstimate(sendRequest.sendAmountAsSats),
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          );
    return tuple;
  }

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
  Tuple2<ravencoin.Transaction, SendEstimate> transaction(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
    Security? security,
  }) {
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);

    // Direct the transaction to send value to the desired address
    // measure fee?
    txb.addOutput(toAddress, estimate.amount);

    // From the available wallets and UTXOs within our wallet,
    // find sufficient value to send to the address above
    // result = addInputs(txb, SendEstimate(sendAmount));
    // send
    var utxos = services.balance.collectUTXOs(
      wallet,
      amount: estimate.total,
      security: security,
    );

    for (var utxo in utxos) {
      txb.addInput(utxo.transactionId, utxo.position);
    }

    var updatedEstimate = SendEstimate.copy(estimate)..setUTXOs(utxos);

    // Calculate change due, and return it to a wallet we control
    var returnAddress = services.wallet.getChangeWallet(wallet).address;
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
      return transaction(
        toAddress,
        updatedEstimate,
        goal: goal,
        wallet: wallet,
        security: security,
      );
    }
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAll(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
    Set<int>? previousFees,
    Security? security,
  }) {
    previousFees = previousFees ?? {};
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);
    var utxos = services.balance.sortedUnspents(wallet);
    var total = 0;
    for (var utxo in utxos) {
      txb.addInput(utxo.transactionId, utxo.position);
      total = total + utxo.securityValue(security: security);
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
      return transactionSendAll(
        toAddress,
        updatedEstimate,
        goal: goal,
        wallet: wallet,
        previousFees: {...previousFees, fees},
        security: security,
      );
    }
  }
}
