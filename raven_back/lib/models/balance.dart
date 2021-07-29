import 'package:raven_electrum_client/methods/get_balance.dart';

import '../records.dart' as records;

class Balance {
  final int confirmed;
  final int unconfirmed;

  Balance(this.confirmed, this.unconfirmed);

  factory Balance.fromScripthashBalance(ScripthashBalance balance) {
    return Balance(balance.confirmed, balance.unconfirmed);
  }

  factory Balance.fromRecord(records.Balance record) {
    return Balance(record.confirmed, record.unconfirmed);
  }

  records.Balance toRecord() {
    return records.Balance(confirmed, unconfirmed);
  }
}
