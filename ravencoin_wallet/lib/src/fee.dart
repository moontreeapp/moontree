/// calculates fees for transactions of various types

class TxGoal {
  final double rate;
  final String? name;
  const TxGoal(
    this.rate, [
    this.name,
  ]);

  int get minimumFee => (0.01 * satsPer).floor(); // relevance?

  /// 100,000,000 sats per RVN
  static int get satsPer => 100000000;
}

class TxGoals {
  static TxGoal cheap = TxGoal(hardRelayFee * 1.0, 'Cheap');
  static TxGoal standard = TxGoal(hardRelayFee * 1.1, 'Standard');
  static TxGoal fast = TxGoal(hardRelayFee * 1.5, 'Fast');

  /// 0.01 RVN = 1,000,000 sats
  static double get hardRelayFee => 10000;
}
