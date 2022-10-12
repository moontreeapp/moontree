import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:ravencoin_back/records/security.dart';
import 'package:ravencoin_back/records/types/chain.dart';
import 'package:ravencoin_back/records/types/net.dart';
import 'package:ravencoin_back/utilities/exceptions.dart';
import 'package:ravencoin_back/utilities/transform.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';

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

  @HiveField(4, defaultValue: Chain.ravencoin)
  Chain chain;

  @HiveField(5, defaultValue: Net.Main)
  Net net;

  Balance({
    required this.walletId,
    required this.security,
    required this.confirmed,
    required this.unconfirmed,
    required this.chain,
    required this.net,
  });

  @override
  List<Object> get props => [
        walletId,
        security,
        confirmed,
        unconfirmed,
        chain,
        net,
      ];

  @override
  String toString() =>
      'Balance($walletId, $security, $confirmed, $unconfirmed, $chain, $net)';

  factory Balance.fromScripthashBalance({
    required String walletId,
    required Security security,
    required ScripthashBalance balance,
    required Chain chain,
    required Net net,
  }) =>
      Balance(
        walletId: walletId,
        security: security,
        confirmed: balance.confirmed,
        unconfirmed: balance.unconfirmed,
        chain: chain,
        net: net,
      );

  factory Balance.fromBalance(
    Balance balance, {
    String? walletId,
    Security? security,
    int? confirmed,
    int? unconfirmed,
    Chain? chain,
    Net? net,
  }) =>
      Balance(
          walletId: walletId ?? balance.walletId,
          security: security ?? balance.security,
          confirmed: confirmed ?? balance.confirmed,
          unconfirmed: unconfirmed ?? balance.unconfirmed,
          chain: chain ?? balance.chain,
          net: net ?? balance.net);

  String get id => Balance.balanceKey(walletId, security);

  String get idChain => Balance.balanceChainKey(walletId, security, chain, net);

  static String balanceKey(String walletId, Security security) =>
      '$walletId:${security.id}';

  static String balanceChainKey(
          String walletId, Security security, Chain chain, Net net) =>
      '$walletId:${security.id}:${chain.name}:${net.name}';

  static String walletChainKey(String walletId, Chain chain, Net net) =>
      '$walletId:${chain.name}:${net.name}';

  static String securityChainKey(Security security, Chain chain, Net net) =>
      '${security.id}:${chain.name}:${net.name}';

  static String chainSymbol(Chain chain) {
    switch (chain) {
      case Chain.ravencoin:
        return 'RVN';
      case Chain.evrmore:
        return 'EVR';
      default:
        return 'RVN';
    }
  }

  int get value => confirmed + unconfirmed;

  double get amount => satToAmount(confirmed + unconfirmed);

  double get currency => (confirmed / 100000000); //+ (unconfirmed / 100000000);

  String get valueRVN =>
      NumberFormat('${chainSymbol(chain)} #,##0.00000000', 'en_US')
          .format(currency);

  Balance operator +(Balance balance) {
    // its ok if they don't match.
    //if (walletId != balance.walletId) {
    //  throw BalanceMismatch("Balance walletId don't match - can't combine");
    //}
    if (security != balance.security) {
      throw BalanceMismatch("Balance securities don't match - can't combine");
    }
    if (chain != balance.chain || net != balance.net) {
      throw BalanceMismatch("Balance blockchains don't match - can't combine");
    }
    return Balance(
      walletId: walletId,
      security: security,
      confirmed: confirmed + balance.confirmed,
      unconfirmed: unconfirmed + balance.unconfirmed,
      chain: chain,
      net: net,
    );
  }
}

class BalanceUSD {
  final double confirmed;
  final double unconfirmed;

  BalanceUSD({required this.confirmed, required this.unconfirmed});

  double get value => confirmed + unconfirmed;

  String get valueUSD => NumberFormat('\$ #,##0.00', 'en_US')
      .format((confirmed /*+ unconfirmed*/) /*.toStringAsFixed(2)*/);

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
