import 'package:raven/raven.dart';
import 'package:ravencoin/ravencoin.dart';

import 'transaction/fee.dart';
import 'transaction/sign.dart';

class FormatResult {
  TransactionBuilder txb;
  int total;
  int fees;
  List<History> utxos;
  FormatResult(this.txb, this.total, this.fees, this.utxos);
}

class TransactionService {
  /// gets inputs, calculates fee, returns change
  TransactionBuilder buildTransaction(
      Account account, String toAddress, int sendAmount,
      [int anticipatedFee = 34 /* why 34? */]) {
    var txb = TransactionBuilder(network: account.network);

    // Direct the transaction to send value to the desired address
    txb.addOutput(toAddress, sendAmount);

    // From the available wallets and UTXOs within our account,
    // find sufficient value to send to the address above
    var results = addInputs(txb, account, sendAmount, anticipatedFee);

    // Calculate change due, and return it to a wallet we control
    var returnAddress = services.accounts.getChangeWallet(account).address;
    var changeDue =
        results.total - (sendAmount + anticipatedFee) - results.fees;
    txb.addOutput(returnAddress, changeDue);

    // Authorize the release of value by signing the transaction UTXOs
    txb.signEachInput(results.utxos);

    return txb;
  }

  /// inputs and fees suffer from a recursive relationship:
  /// this non-recursive function solves it nearly ideally and nearly efficiently.
  /// example problem:
  ///   you have 3 utxos valuing: [1, 3, 10]
  ///   imagine each inputs costs 1 (and imagine outputs are free)
  ///   you wish to send 2 to someone.
  ///   no problem, select your 3 utxo, your send + fees is 2 + 1 = 3 you're done.
  ///   instead imagine you wish to send 3 to someone.
  ///   you select your 3 utxo and that will cover the spend,
  ///   but you must also cover the fee for that input (1),
  ///   so select 1, but now you must cover the fee for that input as well.
  ///   your cost is 3+1+1 = 5, but you have selected a total of 4.
  ///   To solve this we simply try to get the best utxo set for 5 instead:
  ///   which is one utxo (10), so your cost is now really 3+1 and your input is 10. your done.
  FormatResult addInputs(
    TransactionBuilder txb,
    Account account,
    int sendAmount,
    int anticipatedOutputFee,
  ) {
    var total = 0;
    var retutxos = <History>[];
    var pastInputs = [];
    var knownFees = txb.tx!.fee();
    var anticipatedInputFeeRate = 51 /* why 51? */;
    var anticipatedInputFees = 0;
    var utxos = <History>[];

    // find optimal utxo set by anticipating fees depending on chosen inputs and get inputs to cover total
    while (!pastInputs.contains(utxos)) {
      anticipatedInputFees =
          anticipatedInputFeeRate * (utxos.isEmpty ? 1 : utxos.length);
      utxos = services.balances.collectUTXOs(account,
          amount: sendAmount +
              knownFees +
              anticipatedOutputFee +
              anticipatedInputFees);
      pastInputs.add(utxos);
    }
    // we have an optimal utxo set, but which one? most recent or one prior? select the one with fewer inputs
    if (pastInputs.isNotEmpty &&
        (pastInputs[pastInputs.length - 1].length < utxos.length)) {
      utxos = pastInputs[pastInputs.length - 1];
    }
    // add it to the transaction
    for (var utxo in utxos) {
      txb.addInput(utxo.hash, utxo.position);
      total = (total + utxo.value).toInt();
      retutxos.add(utxo);
    }
    // doublecheck we have enough value to cover the amount + anticipated OutputFee + knownFees
    knownFees = txb.tx!.fee();
    var knownCost = sendAmount + anticipatedOutputFee + knownFees;
    while (total < knownCost) {
      // if its not big enough, we simply add one more input to cover the difference
      var utxosForExtra = services.balances.collectUTXOs(
        account,
        amount: knownCost - total,
        except: retutxos, // avoid adding inputs you've already added
      );
      for (var utxo in utxosForExtra) {
        txb.addInput(utxo.hash, utxo.position);
        total = (total + utxo.value).toInt();
        retutxos.add(utxo); // used later, we have to sign after change output
      }
      knownFees = txb.tx!.fee();
      knownCost = sendAmount + anticipatedOutputFee + knownFees;
    }
    return FormatResult(txb, total, knownFees, retutxos);
  }
}
