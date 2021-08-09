import 'package:raven/utils/exceptions.dart';
import 'package:raven_electrum_client/methods/get_balance.dart';
import 'package:raven/records/balance.dart' as records;

class Balance {
  final String accountId;
  final String ticker;
  final int confirmed;
  final int unconfirmed;

  Balance(
      {required this.accountId,
      required this.ticker,
      required this.confirmed,
      required this.unconfirmed});

  factory Balance.fromScripthashBalance(
      {required String accountId,
      required String ticker,
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

  int get value {
    return confirmed + unconfirmed;
  }

  Balance operator +(Balance balance) {
    if (accountId != balance.accountId && balance.accountId != '_') {
      throw BalanceMismatch("Balance accountId don't match - can't combine");
    }
    if (ticker != balance.ticker && balance.ticker != '_') {
      throw BalanceMismatch("Balance tickers don't match - can't combine");
    }
    return Balance(
        accountId: balance.accountId,
        ticker: balance.ticker,
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

class BalanceRaw {
  final int confirmed;
  final int unconfirmed;

  BalanceRaw({required this.confirmed, required this.unconfirmed});

  int get value {
    return confirmed + unconfirmed;
  }

  BalanceRaw operator +(BalanceRaw balanceUSD) {
    return BalanceRaw(
        confirmed: confirmed + balanceUSD.confirmed,
        unconfirmed: unconfirmed + balanceUSD.unconfirmed);
  }
}
