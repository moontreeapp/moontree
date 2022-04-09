import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/validation.dart';

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
  });

  @override
  List<Object> get props => [
        symbol,
        satsInCirculation,
        divisibility,
        reissuable,
        metadata,
        transactionId,
        position,
      ];

  @override
  String toString() => 'Asset(symbol: $symbol, '
      'satsInCirculation: $satsInCirculation, divisibility: $divisibility, '
      'reissuable: $reissuable, metadata: $metadata, transactionId: $transactionId, '
      'position: $position)';

  static String assetKey(String symbol) => symbol;
  String get id => symbol;
  String? get parentId {
    if (assetType == AssetType.Sub) {
      var splits = symbol.split('/');
      return splits.sublist(0, splits.length - 1).join('/');
    }
    if (assetType == AssetType.SubAdmin) {
      var splits = symbol.split('/');
      return splits.sublist(0, splits.length - 1).join('/');
    }
    if (assetType == AssetType.QualifierSub) {
      var splits = symbol.split('/#');
      return splits.sublist(0, splits.length - 1).join('/#');
    }
    if (assetType == AssetType.NFT) {
      var splits = symbol.split('#');
      return splits.sublist(0, splits.length - 1).join('#');
    }
    if (assetType == AssetType.Channel) {
      var splits = symbol.split('~');
      return splits.sublist(0, splits.length - 1).join('~');
    }
    return null;
  }

  String? get shortName {
    if (assetType == AssetType.Sub) {
      var splits = symbol.split('/');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.SubAdmin) {
      var splits = symbol.split('/');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.QualifierSub) {
      var splits = symbol.split('/#');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.NFT) {
      var splits = symbol.split('#');
      return splits[splits.length - 1];
    }
    if (assetType == AssetType.Channel) {
      var splits = symbol.split('~');
      return splits[splits.length - 1];
    }
    return null;
  }

  bool get hasIpfs => metadata.isIpfs;

  bool get hasMetadata => metadata != '';

  bool get isAdmin =>
      assetType == AssetType.Admin || assetType == AssetType.SubAdmin;

  bool get isSubAdmin => assetType == AssetType.SubAdmin;

  bool get isQualifier =>
      assetType == AssetType.Qualifier || assetType == AssetType.QualifierSub;

  bool get isAnySub =>
      assetType == AssetType.QualifierSub ||
      assetType == AssetType.SubAdmin ||
      assetType == AssetType.Sub ||
      assetType == AssetType.NFT ||
      assetType == AssetType.Channel;

  bool get isRestricted => assetType == AssetType.Restricted;
  bool get isMain => assetType == AssetType.Main;
  bool get isNFT => assetType == AssetType.NFT;
  bool get isChannel => assetType == AssetType.NFT;

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
      return AssetType.QualifierSub;
    }
    if (symbol.startsWith('#')) {
      return AssetType.Qualifier;
    }
    if (symbol.startsWith('\$')) {
      return AssetType.Restricted;
    }
    if (symbol.contains('#')) {
      return AssetType.NFT;
    }
    if (symbol.contains('~')) {
      return AssetType.Channel;
    }
    if (symbol.contains('/') && symbol.endsWith('!')) {
      return AssetType.SubAdmin;
    }
    if (symbol.contains('/')) {
      return AssetType.Sub;
    }
    if (symbol.endsWith('!')) {
      return AssetType.Admin;
    }
    return AssetType.Main;
  }

  String get assetTypeName => assetType.enumString;

  bool get isSub =>
      symbol.contains('/') && !(symbol.startsWith('\$') || symbol.endsWith('!'))
          ? true
          : false;
}

enum AssetType {
  Main,
  Admin,
  Restricted,
  NFT,
  Channel,
  Sub,
  SubAdmin,
  Qualifier,
  QualifierSub,
}
