import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:client_back/records/security.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show SatsToAmountExtension, satsPerCoin;

import '_type_id.dart';

part 'balance.g.dart';

@HiveType(typeId: TypeId.Balance)
class Balance with EquatableMixin {
  // do we need unique ID?
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final Security security;

  @HiveField(2)
  final int confirmed;

  @HiveField(3)
  final int unconfirmed;

  const Balance({
    required this.walletId,
    required this.security,
    required this.confirmed,
    required this.unconfirmed,
  });

  factory Balance.from(
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
      unconfirmed: unconfirmed ?? balance.unconfirmed,
    );
  }

  @override
  List<Object> get props =>
      <Object>[walletId, security, confirmed, unconfirmed];

  @override
  String toString() =>
      'Balance($walletId, $security, $confirmed, $unconfirmed)';

  factory Balance.fromScripthashBalance({
    required String walletId,
    required Security security,
    required ScripthashBalance balance,
  }) =>
      Balance(
          walletId: walletId,
          security: security,
          confirmed: balance.confirmed,
          unconfirmed: balance.unconfirmed);

  factory Balance.fromBalance(
    Balance balance, {
    String? walletId,
    Security? security,
    int? confirmed,
    int? unconfirmed,
  }) =>
      Balance(
          walletId: walletId ?? balance.walletId,
          security: security ?? balance.security,
          confirmed: confirmed ?? balance.confirmed,
          unconfirmed: unconfirmed ?? balance.unconfirmed);

  String get id => Balance.key(walletId, security);

  static String key(String walletId, Security security) =>
      '$walletId:${security.id}';

  int get value => confirmed + unconfirmed;

  double get amount => value.asCoin;

  double get rvn => confirmed / satsPerCoin;

  String get valueRVN =>
      NumberFormat('RVN #,##0.00000000', 'en_US').format(rvn);

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

  double get value => confirmed + unconfirmed;

  String get valueUSD => NumberFormat(r'$ #,##0.00', 'en_US')
      .format(confirmed /*+ unconfirmed*/ /*.toStringAsFixed(2)*/);

  BalanceUSD operator +(BalanceUSD balanceUSD) => BalanceUSD(
      confirmed: confirmed + balanceUSD.confirmed,
      unconfirmed: unconfirmed + balanceUSD.unconfirmed);

  BalanceUSD operator *(Balance balance) => BalanceUSD(
      confirmed: confirmed * balance.confirmed,
      unconfirmed: unconfirmed * balance.unconfirmed);

  @override
  String toString() => 'BalanceUSD($confirmed, $unconfirmed)';
}

class BalanceRaw {
  final int confirmed;
  final int unconfirmed;

  BalanceRaw({required this.confirmed, required this.unconfirmed});

  int get value => confirmed + unconfirmed;

  BalanceRaw operator +(BalanceRaw balanceUSD) => BalanceRaw(
      confirmed: confirmed + balanceUSD.confirmed,
      unconfirmed: unconfirmed + balanceUSD.unconfirmed);
}
