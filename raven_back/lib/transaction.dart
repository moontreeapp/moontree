import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/fee.dart' as fee;

class FormatResult {
  TransactionBuilder txb;
  int total;
  int fees;
  FormatResult(this.txb, this.total, this.fees);
}

//Tuple2<TransactionBuilder, int>
//List<dynamic>
FormatResult addInputs(txb, account, amount,
    {total = 0, vin = 0, List? except}) {
  except = except ?? [];
  var fees = fee.totalFeeByBytes(txb);
  var utxos = account.collectUTXOs(amount + fees, except);
  for (var utxo in utxos) {
    txb.addInput(utxo['tx_hash'], utxo['tx_pos']);
    total = (total + utxo['value']).ceil();
    except.add(utxo);
    txb.sign(
        vin: vin,
        keyPair: account
            .node(utxo['node index'], exposure: utxo['exposure'])
            .keyPair);
    vin = vin + 1;
  }
  fees = fee.totalFeeByBytes(txb);
  if (total >= amount + fees) {
    return FormatResult(txb, total, fees);
  } else {
    return addInputs(txb, account, amount,
        total: total, vin: vin, except: except);
  }
}

/*
Adding an ouput after signing inputs fails?
so we have to sign inputs last? why?
Or is this function malformed?

00:33 +9 -1: test\raven_tx_test.dart: choose enough inputs for fee [E]
  Invalid argument(s): No, this would invalidate signatures
  package:bitcoin_flutter/src/transaction_builder.dart 95:7  TransactionBuilder.addOutput
  package:raven/transaction.dart 39:7                        addChangeOutput
  test\raven_tx_test.dart 92:9                               main.<fn>
*/
TransactionBuilder addChangeOutput(txb, account, change) {
  txb.addOutput(account.getNextChangeNode().wallet.address, change);
  return txb;
}
