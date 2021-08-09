import 'package:raven/records/security.dart';

import '../records.dart' as records;

class Rate {
  final Security base; // from RVN ->
  final Security quote; // to USD
  final double rate;

  Rate({required this.base, required this.quote, required this.rate});

  factory Rate.fromRecord(records.Rate record) {
    return Rate(base: record.base, quote: record.quote, rate: record.rate);
  }

  records.Rate toRecord() {
    return records.Rate(base: base, quote: quote, rate: rate);
  }
}
