import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/fee.dart' as fee;

class FormatResult {
  TransactionBuilder txb;
  int total;
  int fees;
  List utxos;
  FormatResult(this.txb, this.total, this.fees, this.utxos);
}

class TransactionBuilderHelper {
  final account;
  int amount;
  String address;
  int anticipatedOutputFee; // anticipating a change output after...

  TransactionBuilderHelper(this.account, this.amount, this.address,
      [this.anticipatedOutputFee = 34]);

  TransactionBuilder buildTransaction() {
    /* gets inputs, calculates fee, returns change */
    var txb = TransactionBuilder(network: account.params.network);
    txb.setVersion(1);
    txb.addOutput(address, amount);
    var results = addInputs(txb);
    txb = addChangeOutput(results.txb,
        results.total - (amount + anticipatedOutputFee) - results.fees);
    txb = signEachInput(txb, results.utxos);
    return txb; //.build().toHex();
  }

  FormatResult addInputs(txb, {total = 0, List? except}) {
    except = except ?? [];
    var fees = fee.totalFeeByBytes(txb);
    var utxos =
        account.collectUTXOs((amount + anticipatedOutputFee) + fees, except);
    var retutxos = [];
    for (var utxo in utxos) {
      txb.addInput(utxo['tx_hash'], utxo['tx_pos']);
      total = (total + utxo['value']).floor();
      // we have to sign after change output
      retutxos.add(utxo);
      // avoid adding inputs you've already added
      except.add(utxo);
    }
    fees = fee.totalFeeByBytes(txb);
    if (total >= (amount + anticipatedOutputFee) + fees) {
      return FormatResult(txb, total, fees, retutxos);
    } else {
      return addInputs(txb, total: total, except: except);
    }
  }

  TransactionBuilder addChangeOutput(txb, change) {
    txb.addOutput(account.getNextChangeNode().wallet.address, change);
    return txb;
  }

  TransactionBuilder signEachInput(txb, utxos) {
    for (var i = 0; i < utxos.length; i++) {
      txb.sign(
          vin: i,
          keyPair: account
              .node(utxos[i]['node index'], exposure: utxos[i]['exposure'])
              .keyPair);
    }
    return txb;
  }
}
