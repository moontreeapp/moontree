/* calculates fees for transactions of various types */

double rateForTransferRVN() {
  // query electrum server or something? get the current fee rate per byte
  return 1.0;
}

int totalFeeByBytes(txb) {
  /* fyi - fees require recursive logic:
  if sum of input values not greater than ouput values plus this derived fee... 
  must get another input large enough to satisfy and, and recalculate the fee and check again...
  finally modify change output and check again...
  */
  int bytes = txb.tx.virtualSize();
  var fee = (rateForTransferRVN() * bytes).ceil();
  return fee;
}

int forCreateAsset(String hex) {
  return 50000000000;
}
