import 'dart:math';
import 'dart:typed_data';

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

  // TODO: ONLY FOR RVN
  Tuple2<ravencoin.Transaction, SendEstimate> transaction(
    String toAddress,
    int amount_sats,
    {
    required Wallet wallet,
    TxGoal? goal,
    Security? security,
    Uint8List? memo,
    }
  ) {
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);

    // From the available wallets and UTXOs within our wallet,
    // find sufficient value to send to the address above
    // result = addInputs(txb, SendEstimate(sendAmount));
    // send
    var utxos = services.balance.collectUTXOs(
      wallet,
      amount: amount_sats,
      security: security,
    );

    for (var utxo in utxos) {
      txb.addInput(utxo.transactionId, utxo.position);
    }
    // Dummy outputs to account for return and actual send
    txb.addOutput(toAddress, 0);
    txb.addOutput(toAddress, 0);

    // Authorize the release of value by signing the transaction UTXOs
    // TODO: Add virtual bytes per vin instead of signing
    txb.signEachInput(utxos);

    var tx = txb.build();
    var fee_sats = tx.fee(goal);
    var sats_in = utxos.fold(0, (int total, vout) => total + vout.rvnValue);
    var sats_returned = sats_in - (security == null ? amount_sats : 0) - fee_sats;
    var return_address = services.wallet.getChangeWallet(wallet).address;

    while (sats_returned < 0) {
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN
      var rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (security == null ? amount_sats : 0) + fee_sats,
        security: null,
      );
      // Grab required assets, if any
      var security_utxos = security != null ? services.balance.collectUTXOs(
        wallet,
        amount: amount_sats,
        security: security,
      ) : [];
      for (var utxo in (rvn_utxos + security_utxos)) {
        txb.addInput(utxo.transactionId, utxo.position);
      }

      // Update avaliable RVN
      sats_in = (rvn_utxos+security_utxos).fold(0, (int total, vout) => total + vout.rvnValue);
      sats_returned = sats_in - (security == null ? amount_sats : 0) - fee_sats;

      // Add actual values
      txb.addOutput(return_address, sats_returned);
      txb.addOutput(toAddress, amount_sats, asset: security?.symbol, memo: memo);

      txb.signEachInput(utxos);
      var tx = txb.build();
      fee_sats = tx.fee(goal);
    }

    //TODO: If doing virtual signing, actually sign here

    return tx;
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
