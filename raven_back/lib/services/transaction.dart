import 'package:raven/raven.dart';
import 'package:ravencoin/ravencoin.dart';

import 'transaction/fee.dart';
import 'transaction/sign.dart';

const ESTIMATED_OUTPUT_FEE = 34 /* why 34? */;
const ESTIMATED_FEE_PER_INPUT = 51 /* why 51? */;

class SendEstimate {
  int amount;
  int fees;
  List<History> utxos;

  int get total => amount + fees;
  int get utxoTotal =>
      utxos.fold(0, (int total, history) => total + history.value);

  int get changeDue => utxoTotal - total;

  SendEstimate(
    this.amount, {
    this.fees = ESTIMATED_OUTPUT_FEE + ESTIMATED_FEE_PER_INPUT,
    List<History>? utxos,
  }) : utxos = utxos ?? [];

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  void setFees(int fees_) => fees = fees_;
  void setUTXOs(List<History> utxos_) => utxos = utxos_;
}

class TransactionService {
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
  TransactionBuilder buildTransaction(
    Account account,
    String toAddress,
    SendEstimate estimate,
  ) {
    var txb = TransactionBuilder(network: account.network);

    // Direct the transaction to send value to the desired address
    // measure fee?
    txb.addOutput(toAddress, estimate.amount);

    // From the available wallets and UTXOs within our account,
    // find sufficient value to send to the address above
    // result = addInputs(txb, account, SendEstimate(sendAmount));
    // send
    var utxos = services.balances.collectUTXOs(account, amount: estimate.total);

    var updatedEstimate = SendEstimate.copy(estimate)..setUTXOs(utxos);

    // Calculate change due, and return it to a wallet we control
    var returnAddress = services.accounts.getChangeWallet(account).address;
    var preliminaryChangeDue = updatedEstimate.changeDue;
    txb.addOutput(returnAddress, preliminaryChangeDue);

    // Authorize the release of value by signing the transaction UTXOs
    txb.signEachInput(utxos);

    updatedEstimate.setFees(txb.tx!.fee());

    if (updatedEstimate.changeDue >= 0 &&
        updatedEstimate.changeDue == preliminaryChangeDue) {
      // success!
      return txb;
    } else {
      // try again
      return buildTransaction(account, toAddress, updatedEstimate);
    }
  }
}
