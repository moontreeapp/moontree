import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/security_type.dart';
import 'package:ravencoin_back/extensions/object.dart';

import '_type_id.dart';

part 'security.g.dart';

@HiveType(typeId: TypeId.Security)
class Security with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final SecurityType securityType;

  const Security({required this.symbol, required this.securityType});

  factory Security.fromSecurity(
    Security other, {
    String? symbol,
    SecurityType? securityType,
  }) =>
      Security(
          symbol: symbol ?? other.symbol,
          securityType: securityType ?? other.securityType);

  @override
  List<Object> get props => [symbol, securityType];

  @override
  String toString() => 'Security(symbol: $symbol, securityType: $securityType)';

  String get id => securityKey(symbol, securityType);

  static String securityKey(String symbol, SecurityType securityType) =>
      '$symbol:${securityType.enumString}';

  String get securityTypeName => securityType.enumString;

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
  bool get isAsset => securityType == SecurityType.RavenAsset;
}
