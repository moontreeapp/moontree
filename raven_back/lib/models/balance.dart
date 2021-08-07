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

  int get value {
    return confirmed + unconfirmed;
  }

  Balance operator +(Balance balance) {
    return Balance(
        confirmed: confirmed + balance.confirmed,
        unconfirmed: unconfirmed + balance.unconfirmed);
  }
}

class BalanceUSD {
  final double confirmed;
  final double unconfirmed;

  BalanceUSD({required this.confirmed, required this.unconfirmed});

  double get value {
    return confirmed + unconfirmed;
  }

  BalanceUSD operator +(BalanceUSD balanceUSD) {
    return BalanceUSD(
        confirmed: confirmed + balanceUSD.confirmed,
        unconfirmed: unconfirmed + balanceUSD.unconfirmed);
  }
}
