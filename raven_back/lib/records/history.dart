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
  String scripthash;

  @HiveField(1)
  int height;

  @HiveField(2)
  String hash;

  @HiveField(3)
  int position;

  @HiveField(4)
  int value;

  @HiveField(5)
  Security security;

  @HiveField(6)
  String? memo;

  @HiveField(7)
  String note;

  History(
      {required this.scripthash,
      required this.height,
      required this.hash,
      this.position = -1,
      this.value = 0,
      this.security = RVN,
      this.memo,
      this.note = ''});

  bool get confirmed => position > -1;

  @override
  List<Object> get props => [
        scripthash,
        height,
        hash,
        position,
        value,
        security,
        memo ?? 'null',
        note,
      ];

  @override
  String toString() {
    return 'History('
        'scripthash: $scripthash, hash: $hash, height: $height, '
        'position: $position, value: $value, security: $security, '
        'memo: $memo, note: $note)';
  }

  // ScripthashHistories should provide a memo, but do they (form electrum? I don't think so)
  factory History.fromScripthashHistory(
      String scripthash, ScripthashHistory history) {
    return History(
      scripthash: scripthash,
      height: history.height,
      hash: history.txHash,
      memo: history.memo,
    );
  }

  // ScripthashHistories should provide a memo, but do they (form electrum? I don't think so)
  factory History.fromScripthashUnspent(
      String scripthash, ScripthashUnspent unspent) {
    return History(
        scripthash: scripthash,
        height: unspent.height,
        hash: unspent.txHash,
        position: unspent.txPos,
        value: unspent.value,
        security: (unspent.ticker == null
            ? RVN
            : Security(
                symbol: unspent.ticker!,
                securityType: SecurityType.RavenAsset)),
        memo: unspent.memo);
  }
}
