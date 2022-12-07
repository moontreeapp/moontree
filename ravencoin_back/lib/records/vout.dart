import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

import '_type_id.dart';

part 'vout.g.dart';

@HiveType(typeId: TypeId.Vout)
class Vout with EquatableMixin, ToStringMixin {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final int position;

  // transaction type 'pubkeyhash' 'transfer_asset' 'new_asset' 'nulldata' etc
  @HiveField(2)
  final String type;

  @HiveField(3)
  final int coinValue; // always RVN

  // amount of asset
  @HiveField(4)
  final int? assetValue;

  // used in asset transfers
  @HiveField(5)
  final String? lockingScript;

  @HiveField(6)
  final String? memo;

  @HiveField(7)
  final String? assetMemo;

  /// other values include
  // final double value;
  // final TxScriptPubKey scriptPubKey; // has pertinent information

  // this is the composite id
  @HiveField(8)
  final String? assetSecurityId;

  // non-multisig transactions // op return memos don't have a to address
  @HiveField(9)
  final String? toAddress;

  // multisig, in addition to toAddress
  @HiveField(10)
  final List<String>? additionalAddresses;

  const Vout({
    required this.transactionId,
    required this.position,
    required this.type,
    required this.coinValue,
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
    int? coinValue,
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
      coinValue: coinValue ?? unspent.value,
      toAddress: toAddress ??
          unspent.address?.address ??
          pros.addresses.primaryIndex
              .getOne(unspent.scripthash, unspent.chain, unspent.net)
              ?.address,
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
  List<Object?> get props => <Object?>[
        transactionId,
        position,
        type,
        coinValue,
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
  List<String> get propNames => <String>[
        'transactionId',
        'position',
        'type',
        'coinValue',
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

  List<String> get toAddresses => <String>[
        if (toAddress != null) toAddress!,
        ...additionalAddresses ?? <String>[]
      ];

  int securityValue({Security? security}) =>
      security == null || security.symbol == pros.securities.currentCoin.symbol
          ? coinValue
          : (security.id == assetSecurityId)
              ? assetValue ?? 0
              : 0;

  String get securityId => assetSecurityId ?? pros.securities.currentCoin.id;

  bool get isAsset =>
      !pros.securities.coins.map((Security e) => e.id).contains(securityId);
}
