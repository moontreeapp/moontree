/* calculates fees for transactions of various types */
import 'package:bitcoin_flutter/bitcoin_flutter.dart';

/// standard fee is 1000 sat per 1kb so .9765625 sat per virtual byte
double standardRate() {
  return 0.9765625;
}

/// not necessary yet
double fastRate() {
  return standardRate() * 1.1;
}

/// not necessary yet
double cheapRate() {
  return standardRate() * 0.9;
}

/// not necessary yet
double customRate() {
  return 1.0;
}

/// not necessary yet
double dynamicRate() {
  return 1.0;
}

var rateSelection = <String, Function>{
  'cheap': cheapRate,
  'fast': fastRate,
  'standard': standardRate,
  'custom': customRate,
  'dynamic': dynamicRate,
};

/// fyi - fees require recursive logic:
/// if sum of input values not greater than ouput values plus this derived fee...
/// must get another input large enough to satisfy and, and recalculate the fee and check again...
/// finally modify change output and check again...
int totalFeeByBytes(TransactionBuilder txb, [String? selection]) {
  int bytes = txb.tx.virtualSize();
  var fee = ((rateSelection[selection] ?? standardRate)() * bytes).ceil();
  return fee;
}

int forCreateAsset(String hex) {
  return 50000000000;
}
