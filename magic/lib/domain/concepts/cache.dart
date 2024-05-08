import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:magic/infrastructure/server/serverv2_client.dart'
    show SerializableEntity;
import 'package:moontree_utils/extensions/bytedata.dart';
import 'dart:convert' as convert;

class CachedServerObject with EquatableMixin {
  final String type;
  final String json;
  //final int? serverId;
  //final String? walletId;
  //final String? symbol;
  //final Chain? chain;
  //final Net? net;
  //final String? txHash;
  //final int? height;

  CachedServerObject({
    required this.type,
    required this.json,
    //this.serverId,
    //this.walletId,
    //this.symbol,
    //this.chain,
    //this.net,
    //this.txHash,
    //this.height,
  });

  //Symbol? get symbolSymbol =>
  //    assetIdReady ? Symbol(symbol!)(chain!, net!) : null;
//
  @override
  List<Object?> get props => <Object?>[
        type,
        json,
        //serverId,
        //walletId,
        //symbol,
        //chain,
        //net,
        //txHash,
        //height,
      ];

  @override
  String toString() => 'CachedServerObject(type:$type, json:$json, ';
  //'serverId:$serverId, walletId:$walletId, symbol:$symbol, chain:$chain, '
  //'net:$net, txHash:$txHash, height:$height)';

  factory CachedServerObject.from(
    SerializableEntity record,
    String type,
    //{
    //  String? walletId,
    //  String? symbol,
    //  Chain? chain,
    //  Net? net,
    //  String? txHash,
    //  int? height,
    //}
  ) =>
      CachedServerObject(
        type: type,
        json: convert.json.encode(
          record.toJson(),
          toEncodable: (dynamic o) {
            if (o is ByteData) {
              return o.toHex();
            }
            if (o is DateTime) {
              return o.toIso8601String();
            }
            return o;
          },
        ),
        //serverId: (record as dynamic).id,
        //walletId: walletId,
        //chain: chain,
        //net: net,
        //symbol: symbol,
        //txHash: txHash,
        //height: height,
      );

  factory CachedServerObject.read(String json) {
    final decodedJson = convert.json.decode(json);
    return CachedServerObject(
      type: decodedJson['type'],
      json: convert.json.encode(decodedJson['json']),
    );
  }

  static String typeKey(String type) => type;
  String get typeId => typeKey(type);
  //
  //static String key(
  //  String type,
  //  int? serverId,
  //  String? txHash,
  //  int? height,
  //  String? symbol,
  //  String? walletId,
  //  Chain? chain,
  //  Net? net,
  //) =>
  //    '$type:$serverId:$txHash:$height:$symbol:$walletId:${ChainNet(chain ?? Chain.none, net ?? Net.main).key}';
  //String get id =>
  //    key(type, serverId, txHash, height, symbol, walletId, chain, net);
  //
  //static String assetKey(String symbol, Chain chain, Net net) =>
  //    '$symbol:${ChainNet(chain, net).key}';
  //String get assetId => assetIdReady ? assetKey(symbol!, chain!, net!) : '';
  //bool get assetIdReady => symbol != null && chain != null && net != null;
  //bool get chainNetReady => chain != null && net != null;
  //
  //static String walletIdKey(String walletId) => '$walletId';
  //String get walletIdId => walletIdIdReady ? walletIdKey(walletId!) : '';
  //bool get walletIdIdReady => walletId != null;
  //
  //static String typeChainNetKey(
  //  String type,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:${ChainNet(chain, net).key}';
  //String get typeChainNetId =>
  //    chain != null && net != null ? typeChainNetKey(type, chain!, net!) : '';
  //
  //static String typeWalletChainNetKey(
  //  String type,
  //  String walletId,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:$walletId:${ChainNet(chain, net).key}';
  //String get typeWalletChainNetId => walletIdIdReady && chainNetReady
  //    ? typeWalletChainNetKey(type, walletId!, chain!, net!)
  //    : '';
  //
  //static String typeSymbolChainNetKey(
  //  String type,
  //  String symbol,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:$symbol:${ChainNet(chain, net).key}';
  //String get typeSymbolChainNetId =>
  //    assetIdReady ? typeSymbolChainNetKey(type, symbol!, chain!, net!) : '';
  //
  //static String typeHashWalletChainNetKey(
  //  String type,
  //  String txHash,
  //  String walletId,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:$txHash:$walletId:${ChainNet(chain, net).key}';
  //String get typeHashWalletChainNetId =>
  //    txHash != null && walletIdIdReady && chainNetReady
  //        ? typeHashWalletChainNetKey(type, txHash!, walletId!, chain!, net!)
  //        : '';
  //
  //static String typeSymbolWalletChainNetKey(
  //  String type,
  //  String symbol,
  //  String walletId,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:$symbol:$walletId:${ChainNet(chain, net).key}';
  //String get typeSymbolWalletChainNetId => walletIdIdReady && assetIdReady
  //    ? typeSymbolWalletChainNetKey(type, symbol!, walletId!, chain!, net!)
  //    : '';
  //
  //static String typeHeightSymbolWalletChainNetKey(
  //  String type,
  //  int height,
  //  String symbol,
  //  String walletId,
  //  Chain chain,
  //  Net net,
  //) =>
  //    '$type:$height:$symbol:$walletId:${ChainNet(chain, net).key}';
  //String get typeHeightSymbolWalletChainNetId =>
  //    height != null && walletIdIdReady && assetIdReady
  //        ? typeHeightSymbolWalletChainNetKey(
  //            type, height!, symbol!, walletId!, chain!, net!)
  //        : '';
}
