import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/security.dart';

import '_type_id.dart';

part 'vout.g.dart';

@HiveType(typeId: TypeId.Vout)
class Vout with EquatableMixin {
  @HiveField(0)
  String transactionId;

  @HiveField(1)
  int rvnValue; // always RVN

  @HiveField(2)
  int position;

  @HiveField(3)
  String memo;

  @HiveField(4)
  String assetMemo;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey; // has pertinent information

  // transaction type 'pubkeyhash' 'transfer_asset' 'new_asset' 'nulldata' etc
  @HiveField(5)
  String type;

  // non-multisig transactions
  @HiveField(6)
  String? toAddress;

  // this is the composite id
  @HiveField(7)
  String? assetSecurityId;

  // amount of asset to send
  @HiveField(8)
  int? assetValue;

  // multisig, in addition to toAddress
  @HiveField(9)
  List<String>? additionalAddresses;

  Vout({
    required this.transactionId,
    required this.rvnValue,
    required this.position,
    this.memo = '',
    this.assetMemo = '',
    required this.type,
    required this.toAddress,
    this.assetSecurityId,
    this.assetValue,
    this.additionalAddresses,
  });

  // this is wrong. confirmed may have had something to do with position back
  // when we were dealing with histories but now confirmed is at the
  // transaction level - was the transaction confirmed or not?
  //bool get confirmed => position > -1;

  @override
  List<Object?> get props => [
        transactionId,
        rvnValue,
        position,
        memo,
        assetMemo,
        type,
        toAddress,
        assetSecurityId,
        assetValue,
        additionalAddresses,
      ];

  @override
  bool? get stringify => true;

  @override
  String toString() {
    return 'Vout('
        'transactionId: $transactionId, rvnValue: $rvnValue, position: $position, '
        'memo: $memo, assetMemo: $assetMemo, type: $type, toAddress: $toAddress, '
        'assetSecurityId: $assetSecurityId, assetValue: $assetValue, '
        'additionalAddresses: $additionalAddresses)';
  }

  String get id => getVoutId(transactionId, position);

  static String getVoutId(String transactionId, int position) =>
      '$transactionId:$position';

  List<String> get toAddresses =>
      [if (toAddress != null) toAddress!, ...additionalAddresses ?? []];

  int securityValue({Security? security}) => security == null ||
          (security.symbol == 'RVN' &&
              security.securityType == SecurityType.Crypto)
      ? rvnValue
      : (security.id == assetSecurityId)
          ? assetValue ?? 0
          : 0;

  String get securityId => assetSecurityId ?? 'RVN:Crypto';
}
