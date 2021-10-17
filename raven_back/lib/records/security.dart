import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/security_type.dart';
import 'package:raven/utils/enum.dart';

import '_type_id.dart';

part 'security.g.dart';

const Security RVN = Security(symbol: 'RVN', securityType: SecurityType.Crypto);
const Security USD = Security(symbol: 'USD', securityType: SecurityType.Fiat);

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

  @HiveField(5) // what is it? the memo in the source vout?
  final String? metadata; // extracted from source vout // usually ipfs or json

  @HiveField(6)
  final String? txId;

  @HiveField(7)
  final int? position;

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
  });

  @override
  List<Object> get props => [symbol, securityType];

  @override
  String toString() => 'Security(symbol: $symbol, securityType: $securityType)';

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
