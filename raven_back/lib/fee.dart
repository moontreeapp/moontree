/* calculates fees for transactions of various types */
import 'package:bitcoin_flutter/bitcoin_flutter.dart';

/// standard fee is 1000 sat per 1kb so .9765625 sat per virtual byte
double standardRate() {
  return 0.9765625;
}

double fastRate() {
  return standardRate() * 1.1;
}

double cheapRate() {
  return standardRate() * 0.9;
}

double customRate() {
  return 1.0;
}

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

int totalFeeByBytes(TransactionBuilder txb, [String? selection]) {
  int bytes = txb.tx.virtualSize();
  var fee = ((rateSelection[selection] ?? standardRate)() * bytes).ceil();
  return fee;
}

int forCreateAsset(String hex) {
  return 50000000000;
}
