import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';
import 'package:raven/records/security_type.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '_type_id.dart';

part 'history.g.dart';

@HiveType(typeId: TypeId.History)
class History with EquatableMixin {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String walletId;

  @HiveField(2)
  String scripthash;

  @HiveField(3)
  int height;

  @HiveField(4)
  String hash;

  @HiveField(5)
  int position;

  @HiveField(6)
  bool confirmed;

  @HiveField(7)
  int value;

  @HiveField(8)
  Security security;

  @HiveField(9)
  String note;

  History(
      {required this.accountId,
      required this.walletId,
      required this.scripthash,
      required this.height,
      required this.hash,
      this.position = -1,
      this.value = 0,
      this.security = RVN,
      this.note = ''})
      : confirmed = (position == -1 ? false : true);

  @override
  List<Object> get props => [
        accountId,
        walletId,
        scripthash,
        height,
        hash,
        position,
        value,
        security.symbol,
        note
      ];

  @override
  String toString() {
    return 'History(walletId: $walletId, accountId: $accountId, scripthash: $scripthash, txHash: $hash, height: $height, txPos: $position, value: $value, security: $security, note: $note)';
  }

  factory History.fromScripthashHistory(String accountId, String walletId,
      String scripthash, ScripthashHistory history) {
    return History(
      accountId: accountId,
      walletId: walletId,
      scripthash: scripthash,
      height: history.height,
      hash: history.txHash,
    );
  }

  factory History.fromScripthashUnspent(String accountId, String walletId,
      String scripthash, ScripthashUnspent unspent) {
    return History(
        accountId: accountId,
        walletId: walletId,
        scripthash: scripthash,
        height: unspent.height,
        hash: unspent.txHash,
        position: unspent.txPos,
        value: unspent.value,
        security: (unspent.ticker == null
            ? RVN
            : Security(
                symbol: unspent.ticker!,
                securityType: SecurityType.RavenAsset)));
  }
}
