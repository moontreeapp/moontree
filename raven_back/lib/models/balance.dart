import 'package:raven_electrum_client/methods/get_balance.dart';

import '../records.dart' as records;

class Balance {
  String ticker;
  final int confirmed;
  final int unconfirmed;

  Balance(
      {required this.ticker,
      required this.confirmed,
      required this.unconfirmed});

  factory Balance.fromScripthashBalance(ScripthashBalance balance) {
    return Balance(
        ticker: '_',
        confirmed: balance.confirmed,
        unconfirmed: balance.unconfirmed);
  }

  factory Balance.fromRecord(records.Balance record) {
    return Balance(
        ticker: record.ticker,
        confirmed: record.confirmed,
        unconfirmed: record.unconfirmed);
  }

  records.Balance toRecord() {
    return records.Balance(
        ticker: ticker, confirmed: confirmed, unconfirmed: unconfirmed);
  }
}
