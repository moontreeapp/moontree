/* calculates fees for transactions of various types */
import 'package:ravencoin/ravencoin.dart';

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
  var byteCount = txb.tx!.virtualSize();
  var fee = ((rateSelection[selection] ?? standardRate)() * byteCount).ceil();
  return fee;
}

int forCreateAsset(String hex) {
  return 50000000000;
}
