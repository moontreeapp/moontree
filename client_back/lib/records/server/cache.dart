import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/_type_id.dart';

part 'cache.g.dart';

@HiveType(typeId: TypeId.CachedServerObject)
class CachedServerObject with EquatableMixin {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String json;

  @HiveField(2)
  final int? serverId;

  @HiveField(3)
  final String? walletId;

  @HiveField(4)
  final String? symbol;

  @HiveField(5)
  final Chain? chain;

  @HiveField(6)
  final Net? net;

  CachedServerObject({
    required this.type,
    required this.json,
    this.serverId,
    this.walletId,
    this.symbol,
    this.chain,
    this.net,
  });

  Symbol? get symbolSymbol =>
      assetIdReady ? Symbol(symbol!)(chain!, net!) : null;

  @override
  List<Object?> get props => <Object?>[
        type,
        json,
        serverId,
        walletId,
        symbol,
        chain,
        net,
      ];

  @override
  String toString() => 'CachedServerObject(type:$type, json:$json, '
      'serverId:$serverId, walletId:$walletId, symbol:$symbol, chain:$chain, '
      'net:$net)';

  static String key(String type) => '$type';
  String get id => key(type);

  static String assetKey(String symbol, Chain chain, Net net) =>
      '$symbol:${ChainNet(chain, net).key}';
  String get assetId => assetIdReady ? assetKey(symbol!, chain!, net!) : '';
  bool get assetIdReady => symbol != null && chain != null && net != null;

  static String walletIdKey(String walletId) => '$walletId';
  String get walletIdId => walletIdIdReady ? walletIdKey(walletId!) : '';
  bool get walletIdIdReady => walletId != null;

  static String typeWalletChainNetKey(
    String type,
    String walletId,
    Chain chain,
    Net net,
  ) =>
      '$type:$walletId:${ChainNet(chain, net).key}';
  String get typeWalletChainNetId => walletIdIdReady && assetIdReady
      ? typeWalletChainNetKey(type, walletId!, chain!, net!)
      : '';
}
