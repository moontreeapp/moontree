/* calculates fees for transactions of various types */
import 'package:ravencoin/ravencoin.dart';

// 100,000,000 sats per RVN
const SATS_PER_RVN = 100000000;

// 0.01 RVN = 1,000,000 sats
int MIN_FEE = (0.01 * SATS_PER_RVN).floor();

class TxGoal {
  final double rate;
  final String? name;
  const TxGoal(this.rate, [this.name]);
}

const double STANDARD_RATE = 1000;

const TxGoal cheap = TxGoal(STANDARD_RATE * 1.0, 'Cheap');
const TxGoal standard = TxGoal(STANDARD_RATE * 1.1, 'Standard');
const TxGoal fast = TxGoal(STANDARD_RATE * 1.5, 'Fast');

int calculateFee(int virtualSize, [TxGoal goal = standard]) =>
    (goal.rate * virtualSize).ceil();

extension TransactionFee on Transaction {
  int fee([TxGoal? goal]) => calculateFee(virtualSize(), goal ?? standard);
}
