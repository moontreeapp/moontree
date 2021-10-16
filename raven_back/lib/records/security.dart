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

  //// perhaps metadata is a different reservoir -
  //// some security types don't have meta data like crypto and fiat...
  /// asset meta data
  //late final int satsInCirculation;
  //late final int divisions; // precision?
  //late final int reissuable;
  //late final int hasIpfs; // what is it? the memo in the source vout?
  //late final TxSource source;
  ////late final String txHash; // where it originated?
  ////late final int txPos; // the vout it originated?
  ////late final int height; // the block it originated?

  const Security({
    required this.symbol,
    required this.securityType,
  });

  @override
  List<Object> get props => [symbol, securityType];

  @override
  String toString() => 'Security(symbol: $symbol, securityType: $securityType)';

  String get securityId => '$symbol:${describeEnum(securityType)}';

  String get securityTypeName => describeEnum(securityType);
}
