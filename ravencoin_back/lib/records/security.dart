import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/types/security_type.dart';
import 'package:ravencoin_back/records/types/chain.dart';
import 'package:ravencoin_back/records/types/net.dart';

import '_type_id.dart';

part 'security.g.dart';

@HiveType(typeId: TypeId.Security)
class Security with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final SecurityType securityType;

  @HiveField(2, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(3, defaultValue: Net.main)
  final Net net;

  const Security({
    required this.symbol,
    required this.securityType,
    required this.chain,
    required this.net,
  });

  factory Security.fromSecurity(
    Security other, {
    String? symbol,
    SecurityType? securityType,
    Chain? chain,
    Net? net,
  }) =>
      Security(
        symbol: symbol ?? other.symbol,
        securityType: securityType ?? other.securityType,
        chain: chain ?? other.chain,
        net: net ?? other.net,
      );

  factory Security.from(
    Security security, {
    SecurityType? securityType,
    String? symbol,
    Chain? chain,
    Net? net,
  }) {
    return Security(
      securityType: securityType ?? security.securityType,
      symbol: symbol ?? (chain != null ? chainSymbol(chain) : security.symbol),
      chain: chain ?? security.chain,
      net: net ?? security.net,
    );
  }

  @override
  List<Object> get props => [symbol, securityType, chain, net];

  @override
  String toString() => 'Security(symbol: $symbol, securityType: $securityType, '
      '${chainNetReadable(chain, net)})';

  String get id => key(symbol, securityType, chain, net);

  static String key(
          String symbol, SecurityType securityType, Chain chain, Net net) =>
      '$symbol:${securityType.name}:${chainNetKey(chain, net)}';

  String get securityTypeName => securityType.name;

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
  bool get isAsset => securityType == SecurityType.asset;
}
