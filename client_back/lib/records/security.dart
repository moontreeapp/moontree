import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/types/security_type.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/net.dart';

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
    this.securityType = SecurityType.coin, // deprecated - redundant.
    required this.chain,
    required this.net,
  });

  factory Security.fromSecurity(
    Security other, {
    String? symbol,
    Chain? chain,
    Net? net,
  }) =>
      Security(
        symbol: symbol ?? other.symbol,
        chain: chain ?? other.chain,
        net: net ?? other.net,
      );

  factory Security.from(
    Security security, {
    String? symbol,
    Chain? chain,
    Net? net,
  }) {
    return Security(
      symbol: symbol ?? security.symbol,
      chain: chain ?? security.chain,
      net: net ?? security.net,
    );
  }

  @override
  List<Object> get props => <Object>[symbol, chain, net];

  @override
  String toString() => 'Security(symbol: $symbol, '
      '${ChainNet(chain, net).readable})';

  String get id => key(symbol, chain, net);

  static String key(String symbol, Chain chain, Net net) =>
      '$symbol:${ChainNet(chain, net).key}';

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112

  bool get isFiat => chain == Chain.none;

  bool get isCoin => chain.symbol == symbol;

  bool get isAsset => !isFiat && !isCoin;

  SecurityType get getSecurityType => isFiat
      ? SecurityType.fiat
      : isCoin
          ? SecurityType.coin
          : SecurityType.asset;

  ChainNet get chainNet => ChainNet(chain, net);
}
