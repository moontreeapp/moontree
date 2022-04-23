import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:raven_back/records/security.dart';
import 'package:raven_back/utilities/exceptions.dart';
import 'package:raven_electrum/raven_electrum.dart';

import '_type_id.dart';

part 'balance.g.dart';

@HiveType(typeId: TypeId.Balance)
class Balance with EquatableMixin {
  // do we need unique ID?
  @HiveField(0)
  String walletId;

  @HiveField(1)
  Security security;

  @HiveField(2)
  int confirmed;

  @HiveField(3)
  int unconfirmed;

  Balance({
    required this.walletId,
    required this.security,
    required this.confirmed,
    required this.unconfirmed,
  });

  @override
  List<Object> get props => [walletId, security, confirmed, unconfirmed];

  @override
  String toString() =>
      'Balance($walletId, $security, $confirmed, $unconfirmed)';

  factory Balance.fromScripthashBalance({
    required String walletId,
    required Security security,
    required ScripthashBalance balance,
  }) {
    return Balance(
        walletId: walletId,
        security: security,
        confirmed: balance.confirmed,
        unconfirmed: balance.unconfirmed);
  }

  factory Balance.fromBalance(
    Balance balance, {
    String? walletId,
    Security? security,
    int? confirmed,
    int? unconfirmed,
  }) {
    return Balance(
        walletId: walletId ?? balance.walletId,
        security: security ?? balance.security,
        confirmed: confirmed ?? balance.confirmed,
        unconfirmed: unconfirmed ?? balance.unconfirmed);
  }

  String get id => Balance.balanceKey(walletId, security);

  static String balanceKey(String walletId, Security security) =>
      '$walletId:${security.id}';

  int get value {
    return confirmed + unconfirmed;
  }

  double get rvn {
    return (confirmed / 100000000); //+ (unconfirmed / 100000000);
  }

  String get valueRVN {
    return NumberFormat('RVN #,##0.00000000', 'en_US').format(rvn);
  }

  Balance operator +(Balance balance) {
    // its ok if they don't match.
    //if (walletId != balance.walletId) {
    //  throw BalanceMismatch("Balance walletId don't match - can't combine");
    //}
    if (security != balance.security) {
      throw BalanceMismatch("Balance securities don't match - can't combine");
    }
    return Balance(
        walletId: walletId,
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

  String get valueUSD {
    return NumberFormat('\$ #,##0.00', 'en_US')
        .format((confirmed /*+ unconfirmed*/) /*.toStringAsFixed(2)*/);
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

  @override
  String toString() => 'BalanceUSD($confirmed, $unconfirmed)';
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
