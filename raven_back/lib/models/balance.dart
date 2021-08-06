import 'package:raven_electrum_client/methods/get_balance.dart';

import '../records.dart' as records;

class Balance {
  final String accountId;
  final String? ticker;
  final int confirmed;
  final int unconfirmed;

  Balance(
      {required this.accountId,
      this.ticker,
      required this.confirmed,
      required this.unconfirmed});

  factory Balance.fromScripthashBalance(
      {required String accountId,
      String? ticker,
      required ScripthashBalance balance}) {
    return Balance(
        accountId: accountId,
        ticker: ticker,
        confirmed: balance.confirmed,
        unconfirmed: balance.unconfirmed);
  }

  factory Balance.fromRecord(records.Balance record) {
    return Balance(
        accountId: record.accountId,
        ticker: record.ticker,
        confirmed: record.confirmed,
        unconfirmed: record.unconfirmed);
  }

  records.Balance toRecord() {
    return records.Balance(
        accountId: accountId,
        ticker: ticker,
        confirmed: confirmed,
        unconfirmed: unconfirmed);
  }
}
