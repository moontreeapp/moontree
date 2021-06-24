import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/account.dart';
import 'package:raven/fee.dart' as fee;

class FormatResult {
  TransactionBuilder txb;
  int total;
  int fees;
  List<UTXO> utxos;
  FormatResult(this.txb, this.total, this.fees, this.utxos);
}

class TransactionBuilderHelper {
  final fromAccount;
  int sendAmount;
  String toAddress;
  int anticipatedOutputFee; // anticipating a change output after...

  TransactionBuilderHelper(this.fromAccount, this.sendAmount, this.toAddress,
      [this.anticipatedOutputFee = 34]);

  TransactionBuilder buildTransaction() {
    /* gets inputs, calculates fee, returns change */
    var txb = TransactionBuilder(network: fromAccount.params.network);
    txb.setVersion(1);
    txb.addOutput(toAddress, sendAmount);
    var results = addInputs(txb);
    txb = addChangeOutput(results.txb,
        results.total - (sendAmount + anticipatedOutputFee) - results.fees);
    txb = signEachInput(txb, results.utxos);
    return txb; //.build().toHex();
  }

  FormatResult addInputs(txb) {
    /*
    inputs and fees suffer from a recursive relationship:
    this non-recursive function solves it nearly ideally and nearly efficiently.
    example problem: 
      you have 3 utxos valuing: [1, 3, 10]
      imagine each inputs costs 1 (and imagine outputs are free)
      you wish to send 2 to someone.
      no problem, select your 3 utxo, your send + fees is 2 + 1 = 3 you're done.
      instead imagine you wish to send 3 to someone.
      you select your 3 utxo and that will cover the spend,
      but you must also cover the fee for that input (1),
      so select 1, but now you must cover the fee for that input as well. 
      your cost is 3+1+1 = 5, but you have selected a total of 4.
      To solve this we simply try to get the best utxo set for 5 instead:
      which is one utxo (10), so your cost is now really 3+1 and your input is 10. your done.
    */
    var total = 0;
    var retutxos = <UTXO>[];
    var pastInputs = [];
    var knownFees = fee.totalFeeByBytes(txb);
    var anticipatedInputFeeRate = 51;
    var anticipatedInputFees = 0;
    var utxos = <UTXO>[];
    // find optimal utxo set by anticipating fees depending on chosen inputs and get inputs to cover total
    while (!pastInputs.contains(utxos)) {
      anticipatedInputFees =
          anticipatedInputFeeRate * (utxos.isEmpty ? 1 : utxos.length);
      utxos = fromAccount.collectUTXOs(
          sendAmount + knownFees + anticipatedOutputFee + anticipatedInputFees);
      pastInputs.add(utxos);
    }
    // we have an optimal utxo set, but which one? most recent or one prior? select the one with fewer inputs
    if (pastInputs.isNotEmpty &&
        (pastInputs[pastInputs.length - 1].length < utxos.length)) {
      utxos = pastInputs[pastInputs.length - 1];
    }
    // add it to the transaction
    for (var utxo in utxos) {
      txb.addInput(utxo.unspent.txHash, utxo.unspent.txPos);
      total = (total + utxo.unspent.value).toInt();
      retutxos.add(utxo);
    }
    // doublecheck we have enough value to cover the amount + anticipated OutputFee + knownFees
    knownFees = fee.totalFeeByBytes(txb);
    var knownCost = sendAmount + anticipatedOutputFee + knownFees;
    while (total < knownCost) {
      // if its not big enough, we simply add one more input to cover the difference
      var utxosForExtra = fromAccount.collectUTXOs(
          amount: knownCost - total,
          except: retutxos); // avoid adding inputs you've already added
      for (var utxo in utxosForExtra) {
        txb.addInput(utxo.unspent.txHash, utxo.unspent.txPos);
        total = (total + utxo.unspent.value).toInt();
        retutxos.add(utxo); // used later, we have to sign after change output
      }
      knownFees = fee.totalFeeByBytes(txb);
      knownCost = sendAmount + anticipatedOutputFee + knownFees;
    }
    return FormatResult(txb, total, knownFees, retutxos);
  }

  TransactionBuilder addChangeOutput(txb, change) {
    txb.addOutput(fromAccount.getNextChangeNode().wallet.address, change);
    return txb;
  }

  TransactionBuilder signEachInput(txb, utxos) {
    for (var i = 0; i < utxos.length; i++) {
      txb.sign(
          vin: i,
          keyPair: fromAccount
              .node(utxos[i].nodeIndex, exposure: utxos[i].exposure)
              .keyPair);
    }
    return txb;
  }
}
