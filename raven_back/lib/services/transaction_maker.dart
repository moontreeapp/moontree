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
  late Security? security;
  late String? assetMemo;
  late String? memo;

  SendRequest({
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    required this.feeGoal,
    required this.wallet,
    this.security,
    this.assetMemo,
    this.memo,
  });
}

class SendEstimate {
  int amount;
  int fees;
  List<Vout> utxos;
  Security? security;
  String? assetMemo;
  String? memo;

  SendEstimate(
    this.amount, {
    this.fees = ESTIMATED_OUTPUT_FEE + ESTIMATED_FEE_PER_INPUT,
    List<Vout>? utxos,
    this.security,
    this.assetMemo,
    this.memo,
  }) : utxos = utxos ?? [];

  @override
  String toString() => 'amount: $amount, fees: $fees, utxos: $utxos';

  int get total => amount + fees;
  int get utxoTotal => utxos.fold(
      0, (int total, vout) => total + vout.securityValue(security: security));

  int get changeDue => utxoTotal - total;

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
    var estimate = SendEstimate(
      sendRequest.sendAmountAsSats,
      security: sendRequest.security,
      assetMemo: sendRequest.assetMemo,
      memo: sendRequest.memo,
    );

    tuple = (sendRequest.sendAll ||
            double.parse(sendRequest.visibleAmount) == sendRequest.holding)
        ? (sendRequest.security == null
            ? transactionSendAllRVN(
                sendRequest.sendAddress,
                estimate,
                wallet: sendRequest.wallet,
                goal: sendRequest.feeGoal,
              )
            : transactionSendAll(
                sendRequest.sendAddress,
                estimate,
                wallet: sendRequest.wallet,
                goal: sendRequest.feeGoal,
              ))
        : transaction(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          );
    return tuple;
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transaction(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) {
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);
    var utxos = services.balance.collectUTXOs(
      wallet,
      amount: estimate.amount,
      security: estimate.security,
    );
    for (var utxo in utxos.toSet()) {
      txb.addInput(utxo.transactionId, utxo.position);
    }
    // Dummy outputs to account for return and actual send
    txb.addOutput(toAddress, 0);
    txb.addOutput(toAddress, 0);

    // Add transaction memo if one is given
    if (estimate.memo != null) {
      txb.addMemo(estimate.memo);
    }

    // Authorize the release of value by signing the transaction UTXOs
    // TODO: Add virtual bytes per vin instead of signing
    txb.signEachInput(utxos);
     
    var tx = txb.build();
    var fee_sats = tx.fee(goal);
    var sats_in = utxos.fold(0, (int total, vout) => total + vout.rvnValue);
    var sats_returned =
        sats_in - (estimate.security == null ? estimate.amount : 0) - fee_sats;
    var return_address = services.wallet.getChangeWallet(wallet).address;
    var rebuild = true;
    while (sats_returned < 0 || rebuild) {
      rebuild = false; // must rebuild transaction at least once.
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee
      var rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (estimate.security == null ? estimate.amount : 0) + fee_sats,
        security: null,
      );
      // Grab required assets for transfer amount
      var security_utxos = services.balance.collectUTXOs(
        wallet,
        amount: estimate.amount,
        security: estimate.security,
      );
      utxos = (rvn_utxos + security_utxos).toSet().toList();
      sats_in = 0;
      for (var utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned = sats_in -
          (estimate.security == null ? estimate.amount : 0) -
          fee_sats;

      // Add actual values
      txb.addOutput(return_address, sats_returned);
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo?.hexBytes,
      );

      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }

      txb.signEachInput(utxos);
      tx = txb.build();
      fee_sats = tx.fee(goal);
    }

    //TODO: If doing virtual signing, actually sign here
    estimate.setFees(fee_sats);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAll(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) {
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);
    var utxos = services.balance.sortedUnspents(
      wallet,
      security: estimate.security,
    );
    var total = 0;
    for (var utxo in utxos.toSet()) {
      txb.addInput(utxo.transactionId, utxo.position);
      total = total + utxo.securityValue(security: estimate.security);
    }
    if (estimate.memo != null) {
      txb.addMemo(estimate.memo);
    }
    estimate.setUTXOs(utxos);
    txb.addOutput(toAddress, estimate.amount);
    txb.signEachInput(utxos);
    var tx = txb.build();
    var fees = tx.fee(goal);
    estimate.setFees(tx.fee(goal));
    estimate.setAmount(total - fees);
    var satsIn = utxos.fold(0, (int total, vout) => total + vout.rvnValue);
    var satsReturn =
        satsIn - (estimate.security == null ? estimate.amount : 0) - fees;
    var return_address = services.wallet.getChangeWallet(wallet).address;
    var rebuild = true;
    while (satsReturn < 0 || rebuild) {
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      List<Vout> rvn_utxos;
      List<Vout> security_utxos;
      if (estimate.security != null) {
        // Grab required RVN for fee
        rvn_utxos = services.balance.collectUTXOs(
          wallet,
          amount: fees,
          security: null,
        );
        security_utxos =
            utxos.where((utxo) => !rvn_utxos.contains(utxo)).toList();
      } else {
        rvn_utxos = [];
        security_utxos = utxos;
      }
      for (var utxo in (rvn_utxos + security_utxos).toSet()) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      // Update avaliable RVN
      satsIn = (rvn_utxos + security_utxos)
          .toSet()
          .fold(0, (int total, vout) => total + vout.rvnValue);
      satsReturn =
          satsIn - (estimate.security == null ? estimate.amount : 0) - fees;
      // Add actual values
      txb.addOutput(return_address, satsReturn);
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo?.hexBytes,
      );
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      txb.signEachInput(utxos);
      tx = txb.build();
      fees = tx.fee(goal);
    }
    estimate.setFees(fees);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAllRVN(
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
      return transactionSendAllRVN(
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
