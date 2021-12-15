import 'dart:math';

import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:tuple/tuple.dart';

import 'transaction/fee.dart';
import 'transaction/sign.dart';

const ESTIMATED_OUTPUT_FEE = 0 /* why 34? */;
const ESTIMATED_FEE_PER_INPUT = 0 /* why 51? */;

class SendRequest {
  late bool useWallet;
  late bool sendAll;
  late String sendAddress;
  late double holding;
  late String visibleAmount;
  late int sendAmountAsSats;
  late TxGoal feeGoal;
  Wallet? wallet;
  Account? account;

  SendRequest({
    required this.useWallet,
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    required this.feeGoal,
    this.wallet,
    this.account,
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
    if (sendRequest.useWallet) {
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
    } else {
      tuple = (sendRequest.sendAll ||
              double.parse(sendRequest.visibleAmount) == sendRequest.holding)
          ? transactionSendAll(
              sendRequest.sendAddress,
              SendEstimate(sendRequest.sendAmountAsSats),
              account: sendRequest.account,
              goal: sendRequest.feeGoal,
            )
          : transaction(
              sendRequest.sendAddress,
              SendEstimate(sendRequest.sendAmountAsSats),
              account: sendRequest.account,
              goal: sendRequest.feeGoal,
            );
    }
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
    Account? account,
    Wallet? wallet,
    TxGoal? goal,
    Security? security,
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
        ? services.balance.collectUTXOsWallet(wallet!,
            amount: estimate.total, security: security)
        : services.balance
            .collectUTXOs(account!, amount: estimate.total, security: security);

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
      return transaction(
        toAddress,
        updatedEstimate,
        goal: goal,
        account: account,
        wallet: wallet,
        security: security,
      );
    }
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAll(
    String toAddress,
    SendEstimate estimate, {
    Account? account,
    Wallet? wallet,
    TxGoal? goal,
    Set<int>? previousFees,
    Security? security,
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
        account: account,
        wallet: wallet,
        previousFees: {...previousFees, fees},
        security: security,
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
