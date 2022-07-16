import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

import '_type_id.dart';

part 'vout.g.dart';

@HiveType(typeId: TypeId.Vout)
class Vout with EquatableMixin, ToStringMixin {
  @HiveField(0)
  String transactionId;

  @HiveField(1)
  int position;

  // transaction type 'pubkeyhash' 'transfer_asset' 'new_asset' 'nulldata' etc
  @HiveField(2)
  String type;

  @HiveField(3)
  int rvnValue; // always RVN

  // amount of asset
  @HiveField(4)
  int? assetValue;

  // used in asset transfers
  @HiveField(5)
  String? lockingScript;

  @HiveField(6)
  String? memo;

  @HiveField(7)
  String? assetMemo;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey; // has pertinent information

  // this is the composite id
  @HiveField(8)
  String? assetSecurityId;

  // non-multisig transactions // op return memos don't have a to address
  @HiveField(9)
  String? toAddress;

  // multisig, in addition to toAddress
  @HiveField(10)
  List<String>? additionalAddresses;

  Vout({
    required this.transactionId,
    required this.position,
    required this.type,
    required this.rvnValue,
    this.assetValue,
    this.lockingScript,
    this.memo,
    this.assetMemo,
    this.assetSecurityId,
    this.toAddress,
    this.additionalAddresses,
  });

  // this is wrong. confirmed may have had something to do with position back
  // when we were dealing with histories but now confirmed is at the
  // transaction level - was the transaction confirmed or not?
  //bool get confirmed => position > -1;

  @override
  List<Object?> get props => [
        transactionId,
        position,
        type,
        rvnValue,
        assetValue,
        lockingScript,
        memo,
        assetMemo,
        assetSecurityId,
        toAddress,
        additionalAddresses,
      ];

  @override
  bool? get stringify => true;

  @override
  List<String> get propNames => [
        'transactionId',
        'position',
        'type',
        'rvnValue',
        'assetValue',
        'lockingScript',
        'memo',
        'assetMemo',
        'assetSecurityId',
        'toAddress',
        'additionalAddresses',
      ];

  String get id => getVoutId(transactionId, position);

  static String getVoutId(String transactionId, int position) =>
      '$transactionId:$position';

  List<String> get toAddresses =>
      [if (toAddress != null) toAddress!, ...additionalAddresses ?? []];

  int securityValue({Security? security}) => security == null ||
          (security.symbol == pros.securities.RVN.symbol &&
              security.securityType == SecurityType.Crypto)
      ? rvnValue
      : (security.id == assetSecurityId)
          ? assetValue ?? 0
          : 0;

  String get securityId => assetSecurityId ?? pros.securities.RVN.id;

  bool get isAsset => securityId != pros.securities.RVN.id;
}
