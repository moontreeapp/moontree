import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security_type.dart';
import 'package:raven/utils/enum.dart';

import '_type_id.dart';

part 'security.g.dart';

@HiveType(typeId: TypeId.Security)
class Security with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final SecurityType securityType;

  @HiveField(2)
  final int? satsInCirculation;

  @HiveField(3)
  final int? precision;

  @HiveField(4)
  final bool? reissuable;

  @HiveField(5)
  final String? metadata;

  @HiveField(6)
  final String? txId;

  @HiveField(7)
  final int? position;

  /// metadata is often an ipfsHash of json which often includes an ipfsHash
  /// for the logo. Instead of looking it up everytime, since there is no hard
  /// format, we save the ipfsLogo hash on the object when we figure it out.
  /// we do not derive the ipfsLogo upon record creation, instead we wait until
  /// the ...
  /// null means we have not looked, empty string means we've looked and found
  /// no viable logo in the metadata, anything else should be a ipfs hash of the
  /// logo, or any kind of hash (since the hash matches the filename).
  @HiveField(8)
  final String? ipfsLogo;

  //late final TxSource source;
  ////late final String txHash; // where it originated?
  ////late final int txPos; // the vout it originated?
  ////late final int height; // the block it originated? // not necessary

  const Security({
    required this.symbol,
    required this.securityType,
    // rvn asset meta data
    this.satsInCirculation,
    this.precision,
    this.reissuable,
    this.metadata,
    this.txId,
    this.position,
    this.ipfsLogo,
  });

  factory Security.fromSecurity(
    Security other, {
    String? symbol,
    SecurityType? securityType,
    int? satsInCirculation,
    int? precision,
    bool? reissuable,
    String? metadata,
    String? txId,
    int? position,
    String? ipfsLogo,
  }) =>
      Security(
        symbol: symbol ?? other.symbol,
        securityType: securityType ?? other.securityType,
        satsInCirculation: satsInCirculation ?? other.satsInCirculation,
        precision: precision ?? other.precision,
        reissuable: reissuable ?? other.reissuable,
        metadata: metadata ?? other.metadata,
        txId: txId ?? other.txId,
        position: position ?? other.position,
        ipfsLogo: ipfsLogo ?? other.ipfsLogo,
      );

  @override
  List<Object> get props => [symbol, securityType];

  @override
  String toString() => 'Security(symbol: $symbol, securityType: $securityType, '
      'satsInCirculation: $satsInCirculation, precision: $precision, '
      'reissuable: $reissuable, metadata: $metadata, txId: $txId, '
      'position: $position, ipfsLogo: $ipfsLogo)';

  static String securityIdKey(String symbol, SecurityType securityType) =>
      '$symbol:${describeEnum(securityType)}';

  String get securityId => '$symbol:$securityTypeName';

  String get securityTypeName => describeEnum(securityType);

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
  bool get hasIpfs =>
      metadata != null && metadata != '' && metadata!.length == 32;

  bool get hasMetadata => metadata != null && metadata != '';
}
