import 'package:raven_electrum_client/methods/get_balance.dart';

import '../records.dart' as records;

class Balance {
  final int confirmed;
  final int unconfirmed;

  Balance({required this.confirmed, required this.unconfirmed});

  factory Balance.fromScripthashBalance({required ScripthashBalance balance}) {
    return Balance(
        confirmed: balance.confirmed, unconfirmed: balance.unconfirmed);
  }

  factory Balance.fromRecord(records.Balance record) {
    return Balance(
        confirmed: record.confirmed, unconfirmed: record.unconfirmed);
  }

  records.Balance toRecord() {
    return records.Balance(confirmed: confirmed, unconfirmed: unconfirmed);
  }
}
