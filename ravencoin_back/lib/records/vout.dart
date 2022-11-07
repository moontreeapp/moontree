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

  factory Vout.fromUnspent(
    Unspent unspent, {
    String? transactionId,
    int? position,
    String? type,
    int? rvnValue,
    int? assetValue,
    String? lockingScript,
    String? memo,
    String? assetMemo,
    String? assetSecurityId,
    String? toAddress,
    List<String>? additionalAddresses,
  }) {
    return Vout(
      transactionId: transactionId ?? unspent.txHash,
      position: position ?? unspent.position,
      type: type ?? 'pubkeyhash',
      rvnValue: rvnValue ?? unspent.value,
      toAddress: toAddress ??
          unspent.address?.address ??
          pros.addresses.byScripthash.getOne(unspent.scripthash)?.address,
      assetValue: assetValue,
      lockingScript: lockingScript,
      memo: memo,
      assetMemo: assetMemo,
      assetSecurityId: assetSecurityId,
      additionalAddresses: additionalAddresses,
    );
  }

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

  String get id => key(transactionId, position);

  static String key(String transactionId, int position) =>
      '$transactionId:$position';

  List<String> get toAddresses =>
      [if (toAddress != null) toAddress!, ...additionalAddresses ?? []];

  int securityValue({Security? security}) => security == null ||
          (security.symbol == pros.securities.currentCrypto.symbol &&
              security.securityType == SecurityType.crypto)
      ? rvnValue
      : (security.id == assetSecurityId)
          ? assetValue ?? 0
          : 0;

  String get securityId => assetSecurityId ?? pros.securities.currentCrypto.id;

  bool get isAsset =>
      !pros.securities.cryptos.map((e) => e.id).contains(securityId);
}
