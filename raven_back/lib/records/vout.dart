import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';

import '_type_id.dart';

part 'vout.g.dart';

@HiveType(typeId: TypeId.Vout)
class Vout with EquatableMixin {
  @HiveField(0)
  String txId;

  @HiveField(1)
  int value;

  @HiveField(2)
  int position;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey;

  // should be securityId to a reservoir of securities and their meta data.
  @HiveField(3)
  Security security;

  @HiveField(4)
  String memo;

  Vout({
    required this.txId,
    required this.value,
    required this.position,
    this.security = RVN,
    this.memo = '',
  });

  bool get confirmed => position > -1;

  @override
  List<Object> get props => [txId, value, position, security];

  @override
  String toString() {
    return 'Vout('
        'txId: $txId, value: $value, position: $position, security: $security, memo: $memo)';
  }

  String get voutId => getVoutId(txId, position);
  static String getVoutId(txId, position) => '$txId:$position';
}
