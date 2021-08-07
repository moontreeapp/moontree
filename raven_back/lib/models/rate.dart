import '../records.dart' as records;

class Rate {
  final String from;
  final String to;
  final double rate;
  final bool fiat;

  Rate(
      {required this.from,
      required this.to,
      required this.rate,
      required this.fiat});

  factory Rate.fromRecord(records.Rate record) {
    return Rate(
        from: record.from, to: record.to, rate: record.rate, fiat: record.fiat);
  }

  records.Rate toRecord() {
    return records.Rate(from: from, to: to, rate: rate, fiat: fiat);
  }
}
