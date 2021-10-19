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
  int value; // always RVN

  @HiveField(2)
  int position;

  @HiveField(3)
  String securityId;

  @HiveField(4)
  String memo;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey; // has pertinate information

  // transaction type 'pubkeyhash' 'transfer_asset' 'new_asset' 'nulldata' etc
  @HiveField(5)
  String type;

  @HiveField(6) // non-multisig transactions
  String toAddress;

  @HiveField(7)
  String? asset; // if sending an asset, what is the name?

  @HiveField(8)
  int? amount; // amount of asset to send

  @HiveField(9) // multisig
  List<String>? additionalAddresses;

  Vout({
    required this.txId,
    required this.value,
    required this.position,
    required this.securityId,
    required this.type,
    required this.toAddress,
    this.additionalAddresses,
    this.memo = '',
    this.asset,
    this.amount,
  });

  bool get confirmed => position > -1;

  @override
  List<Object> get props => [
        txId,
        value,
        position,
        securityId,
        type,
        toAddress,
        memo,
        asset ?? '',
        amount ?? -1,
        additionalAddresses ?? [],
      ];

  @override
  String toString() {
    return 'Vout('
        'txId: $txId, value: $value, position: $position, '
        'securityId: $securityId, memo: $memo, type: $type, '
        'toAddress: $toAddress, memo: $memo, asset: $asset, amount: $amount, '
        'additionalAddress: $additionalAddresses)';
  }

  String get voutId => getVoutId(txId, position);
  static String getVoutId(txId, position) => '$txId:$position';

  List<String> get toAddresses => [toAddress, ...additionalAddresses ?? []];
}
