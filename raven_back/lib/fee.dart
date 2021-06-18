/* calculates fees for transactions of various types */

double standardRate() {
  // query electrum server or something? get the current fee rate per byte
  return 1.0;
}

double fastRate() {
  // query electrum server or something? get the current fee rate per byte
  return standardRate() * 1.1;
}

double cheapRate() {
  // query electrum server or something? get the current fee rate per byte
  return standardRate() * 0.9;
}

var rateSelection = <String, Function>{
  'cheap': cheapRate,
  'fast': fastRate,
  'standard': standardRate,
};

int totalFeeByBytes(txb, [selection]) {
  /* fyi - fees require recursive logic:
  if sum of input values not greater than ouput values plus this derived fee... 
  must get another input large enough to satisfy and, and recalculate the fee and check again...
  finally modify change output and check again...
  */
  int bytes = txb.tx.virtualSize();
  var fee = ((rateSelection[selection] ?? standardRate)() * bytes).ceil();
  return fee;
}

int forCreateAsset(String hex) {
  return 50000000000;
}
