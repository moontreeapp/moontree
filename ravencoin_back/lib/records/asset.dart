import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:ravencoin_back/records/types/chain.dart';
import 'package:ravencoin_back/records/types/net.dart';

import '_type_id.dart';

part 'asset.g.dart';

@HiveType(typeId: TypeId.Asset)
class Asset with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final int satsInCirculation;

  @HiveField(2)
  final int divisibility;

  @HiveField(3)
  final bool reissuable;

  @HiveField(4)
  final String metadata;

  @HiveField(5)
  final String transactionId;

  @HiveField(6)
  final int position;

  @HiveField(7, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(8, defaultValue: Net.main)
  final Net net;

  //late final TxSource source;
  ////late final String txHash; // where it originated?
  ////late final int txPos; // the vout it originated?
  ////late final int height; // the block it originated? // not necessary

  const Asset({
    required this.symbol,
    required this.satsInCirculation,
    required this.divisibility,
    required this.reissuable,
    required this.metadata,
    required this.transactionId,
    required this.position,
    required this.chain,
    required this.net,
  });

  @override
  List<Object> get props => <Object>[
        symbol,
        satsInCirculation,
        divisibility,
        reissuable,
        metadata,
        transactionId,
        position,
        chain,
        net,
      ];

  @override
  String toString() => 'Asset(symbol: $symbol, '
      'satsInCirculation: $satsInCirculation, divisibility: $divisibility, '
      'reissuable: $reissuable, metadata: $metadata, transactionId: $transactionId, '
      'position: $position, ${ChainNet(chain, net).readable})';

  factory Asset.from(
    Asset asset, {
    int? satsInCirculation,
    int? divisibility,
    bool? reissuable,
    String? metadata,
    String? transactionId,
    int? position,
    String? symbol,
    Chain? chain,
    Net? net,
  }) {
    return Asset(
      satsInCirculation: satsInCirculation ?? asset.satsInCirculation,
      divisibility: divisibility ?? asset.divisibility,
      reissuable: reissuable ?? asset.reissuable,
      metadata: metadata ?? asset.metadata,
      transactionId: transactionId ?? asset.transactionId,
      position: position ?? asset.position,
      symbol: symbol ?? (chain != null ? chain.symbol : asset.symbol),
      chain: chain ?? asset.chain,
      net: net ?? asset.net,
    );
  }

  static String key(String symbol, Chain chain, Net net) =>
      '$symbol:${ChainNet(chain, net).key}';

  String get id => key(symbol, chain, net);
  String? get parentSymbol {
    if (assetType == AssetType.sub) {
      final List<String> splits = symbol.split('/');
      return splits.sublist(0, splits.length - 1).join('/');
    }
    if (assetType == AssetType.subAdmin) {
      final List<String> splits = symbol.split('/');
      return splits.sublist(0, splits.length - 1).join('/');
    }
    if (assetType == AssetType.qualifierSub) {
      final List<String> splits = symbol.split('/#');
      return splits.sublist(0, splits.length - 1).join('/#');
    }
    if (assetType == AssetType.unique) {
      final List<String> splits = symbol.split('#');
      return splits.sublist(0, splits.length - 1).join('#');
    }
    if (assetType == AssetType.channel) {
      final List<String> splits = symbol.split('~');
      return splits.sublist(0, splits.length - 1).join('~');
    }
    return null;
  }

  String? get parentId =>
      parentSymbol == null ? null : key(parentSymbol!, chain, net);

  String? get shortName {
    if (assetType == AssetType.sub) {
      final List<String> splits = symbol.split('/');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.subAdmin) {
      final List<String> splits = symbol.split('/');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.qualifierSub) {
      final List<String> splits = symbol.split('/#');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.unique) {
      final List<String> splits = symbol.split('#');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.channel) {
      final List<String> splits = symbol.split('~');
      return splits[splits.length - 1];
    }
    return null;
  }

  bool get hasData => metadata.isAssetData;

  String? get data => hasData ? metadata : null;

  bool get hasMetadata => metadata != '';

  bool get isAdmin =>
      assetType == AssetType.admin || assetType == AssetType.subAdmin;

  bool get isSubAdmin => assetType == AssetType.subAdmin;

  bool get isQualifier =>
      assetType == AssetType.qualifier || assetType == AssetType.qualifierSub;

  bool get isAnySub =>
      assetType == AssetType.qualifierSub ||
      assetType == AssetType.subAdmin ||
      assetType == AssetType.sub ||
      assetType == AssetType.unique ||
      assetType == AssetType.channel;

  bool get isRestricted => assetType == AssetType.restricted;
  bool get isMain => assetType == AssetType.main;
  bool get isNFT => assetType == AssetType.unique;
  bool get isChannel => assetType == AssetType.unique;

  String get baseSymbol => symbol.startsWith('#') || symbol.startsWith('\$')
      ? symbol.substring(1, symbol.length)
      : symbol.endsWith('!')
          ? symbol.substring(0, symbol.length - 1)
          : symbol;

  String get baseSubSymbol => symbol.startsWith('#') || symbol.startsWith('\$')
      ? symbol.substring(1, symbol.length)
      : symbol.endsWith('!')
          ? symbol.substring(0, symbol.length - 1)
          : symbol.replaceAll('#', '/');

  String get adminSymbol => baseSymbol + '!';

  AssetType get assetType => assetTypeOf(symbol);

  static AssetType assetTypeOf(String symbol) {
    if (symbol.startsWith('#') && symbol.contains('/')) {
      return AssetType.qualifierSub;
    }
    if (symbol.startsWith('#')) {
      return AssetType.qualifier;
    }
    if (symbol.startsWith('\$')) {
      return AssetType.restricted;
    }
    if (symbol.contains('#')) {
      return AssetType.unique;
    }
    if (symbol.contains('~')) {
      return AssetType.channel;
    }
    if (symbol.contains('/') && symbol.endsWith('!')) {
      return AssetType.subAdmin;
    }
    if (symbol.contains('/')) {
      return AssetType.sub;
    }
    if (symbol.endsWith('!')) {
      return AssetType.admin;
    }
    return AssetType.main;
  }

  String get assetTypeName => assetType.name;

  double get amount => satToAmount(satsInCirculation);
}

enum AssetType {
  main,
  admin,
  restricted,
  unique,
  channel,
  sub,
  subAdmin,
  qualifier,
  qualifierSub,
}
