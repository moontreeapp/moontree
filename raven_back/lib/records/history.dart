/// Histories are like transactions, but hold only the information we really
/// care about: Ids, security, value (in or out (negative)).
/// to get the correct UTXOs we need to know if a 'history' has been spent...
///   we either need to modify an existing history record when we see it spent
///   or we have to add a new history record linking to the first one...
///   we should probably make a new one...
///     if we do that maybe we should adopt the transaction model which holds
///     both Vins and Vouts? because a history item is basically a vin or vout
///     with extra tx data on it...

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
  String addressId;

  @HiveField(1)
  String txId;

  @HiveField(2)
  int height;

  @HiveField(3)
  int position; // voutPosition

  @HiveField(4)
  int value;

  // should be securityId to a reservoir of securities and their meta data.
  @HiveField(5)
  Security security;

  // should be on a tx?
  @HiveField(6)
  String? memo;

  @HiveField(7)
  String note;

  History(
      {required this.addressId,
      required this.height,
      required this.txId,
      this.position = -1,
      this.value = 0,
      this.security = RVN,
      this.memo,
      this.note = ''});

  bool get confirmed => position > -1;

  @override
  List<Object> get props => [
        addressId,
        height,
        txId,
        position,
        value,
        security,
        memo ?? 'null',
        note,
      ];

  @override
  String toString() {
    return 'History('
        'addressId: $addressId, txId: $txId, height: $height, '
        'position: $position, value: $value, security: $security, '
        'memo: $memo, note: $note)';
  }

  // ScripthashHistories should provide a memo, but do they (form electrum? I don't think so)
  factory History.fromScripthashHistory(
      String addressId, ScripthashHistory history) {
    return History(
      addressId: addressId,
      height: history.height,
      txId: history.txHash,
      memo: history.memo,
    );
  }

  // ScripthashHistories should provide a memo, but do they (form electrum? I don't think so)
  factory History.fromScripthashUnspent(
      String addressId, ScripthashUnspent unspent) {
    return History(
        addressId: addressId,
        height: unspent.height,
        txId: unspent.txHash,
        position: unspent.txPos,
        value: unspent.value,
        security: (unspent.ticker == null
            ? RVN
            : Security(
                symbol: unspent.ticker!,
                securityType: SecurityType.RavenAsset)),
        memo: unspent.memo);
  }

  String get scripthash => addressId;
}
