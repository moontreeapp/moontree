/* calculates fees for transactions of various types */
import 'package:ravencoin/ravencoin.dart';

class TxGoal {
  final double rate;
  const TxGoal(this.rate);
}

/// standard fee is 1000 sat per 1kb so .9765625 sat per virtual byte
const double STANDARD_RATE = 0.9765625;

const TxGoal standard = TxGoal(STANDARD_RATE);
const TxGoal fast = TxGoal(STANDARD_RATE * 1.1);
const TxGoal cheap = TxGoal(STANDARD_RATE * 0.9);

extension TransactionFee on Transaction {
  int fee([TxGoal goal = standard]) => (goal.rate * virtualSize()).ceil();
}

// Is this used?
int forCreateAsset(String hex) {
  return 50000000000;
}
