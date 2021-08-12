import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';
import 'package:raven/utils/exceptions.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

part 'balance.g.dart';

@HiveType(typeId: 3)
class Balance with EquatableMixin {
  // do we need unique ID?
  @HiveField(0)
  String accountId;

  @HiveField(1)
  Security security;

  @HiveField(2)
  int confirmed;

  @HiveField(3)
  int unconfirmed;

  Balance({
    required this.accountId,
    required this.security,
    required this.confirmed,
    required this.unconfirmed,
  });

  @override
  List<Object> get props => [accountId, security, confirmed, unconfirmed];

  @override
  String toString() =>
      'Account($accountId, $security, $confirmed, $unconfirmed)';

  factory Balance.fromScripthashBalance(
      {required String accountId,
      required Security security,
      required ScripthashBalance balance}) {
    return Balance(
        accountId: accountId,
        security: security,
        confirmed: balance.confirmed,
        unconfirmed: balance.unconfirmed);
  }

  int get value {
    return confirmed + unconfirmed;
  }

  Balance operator +(Balance balance) {
    if (accountId != balance.accountId) {
      throw BalanceMismatch("Balance accountId don't match - can't combine");
    }
    if (security != balance.security) {
      throw BalanceMismatch("Balance securities don't match - can't combine");
    }
    return Balance(
        accountId: accountId,
        security: security,
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

  BalanceUSD operator *(Balance balance) {
    return BalanceUSD(
        confirmed: confirmed * balance.confirmed,
        unconfirmed: unconfirmed * balance.unconfirmed);
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
