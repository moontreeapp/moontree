import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/fee.dart' as fee;

class FormatResult {
  TransactionBuilder txb;
  int total;
  int fees;
  List vins;
  List utxos;
  FormatResult(this.txb, this.total, this.fees, this.vins, this.utxos);
}

class TransactionBuilderHelper {
  final account;
  int amount;
  String address;

  TransactionBuilderHelper(this.account, this.amount, this.address);

  TransactionBuilder buildTransaction() {
    var txb = TransactionBuilder(network: account.params.network);
    txb.setVersion(1);
    txb.addOutput(address, amount);
    amount = amount + 34; // anticipating a change output after...
    var results = addInputs(txb);
    txb = addChangeOutput(results.txb, results.total - results.fees);
    txb = signEachInput(txb, results.vins, results.utxos);
    return txb; //.build().toHex();
  }

  FormatResult addInputs(txb, {total = 0, vin = 0, List? except}) {
    except = except ?? [];
    var fees = fee.totalFeeByBytes(txb);
    var utxos = account.collectUTXOs(amount + fees, except);
    var vins = [];
    var retutxos = [];
    for (var utxo in utxos) {
      txb.addInput(utxo['tx_hash'], utxo['tx_pos']);
      total = (total + utxo['value']).ceil();
      // we have to sign after change output
      vins.add(vin);
      retutxos.add(utxo);
      // avoid adding inputs you've already added
      except.add(utxo);
      vin = vin + 1;
    }
    fees = fee.totalFeeByBytes(txb);
    if (total >= amount + fees) {
      return FormatResult(txb, total, fees, vins, retutxos);
    } else {
      return addInputs(txb, total: total, vin: vin, except: except);
    }
  }

  TransactionBuilder addChangeOutput(txb, change) {
    txb.addOutput(account.getNextChangeNode().wallet.address, change);
    return txb;
  }

  TransactionBuilder signEachInput(txb, vins, utxos) {
    for (var i = 0; i < vins.length; i++) {
      txb.sign(
          vin: vins[i],
          keyPair: account
              .node(utxos[i]['node index'], exposure: utxos[i]['exposure'])
              .keyPair);
    }
    return txb;
  }
}
