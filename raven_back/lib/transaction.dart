import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/fee.dart' as fee;

TransactionBuilder addInputs(account, txb, amount,
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
    return txb;
  } else {
    return addInputs(account, txb, amount,
        total: total, vin: vin, except: except);
  }
}
