import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/extensions/object.dart';

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

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
  bool get hasIpfs =>
      metadata != '' &&
      metadata.contains(RegExp(
          r'Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,}'));

  bool get hasMetadata => metadata != '';

  bool get isAdmin => assetType == AssetType.Admin;

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

  AssetType get assetType {
    if (symbol.startsWith('#') && symbol.contains('/')) {
      return AssetType.QualifierSub;
    }
    if (symbol.startsWith('#')) {
      return AssetType.Qualifier;
    }
    if (symbol.startsWith('\$') && symbol.endsWith('!')) {
      return AssetType.RestrictedAdmin;
    }
    if (symbol.startsWith('\$')) {
      return AssetType.Restricted;
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
    if (symbol.contains('#')) {
      return AssetType.NFT;
    }
    if (symbol.contains('~')) {
      return AssetType.Channel;
    }
    return AssetType.Main;
  }

  String get assetTypeName => assetType.enumString;

  bool get isSub =>
      symbol.contains('/') && !(symbol.startsWith('\$') || symbol.endsWith('!'))
          ? true
          : false;

  //String? get subSymbol => main ? '/${symbol}' : null; // sub mains allowed
  //String? get adminSymbol => admin ? '${symbol}!' : null; // must be top
  //String? get restrictedSymbol =>
  //    restricted ? '\$${symbol}' : null; // must be top
  //String? get qualifierSymbol =>
  //    qualifier ? '#${symbol}' : null; // sub qualifiers allowed
  //String? get uniqueSymbol => unique ? '#${symbol}' : null; // must be subasset
  //String? get channelSymbol =>
  //    channel ? '~${symbol}' : null; // must be subasset
}

enum AssetType {
  Main,
  Admin,
  Restricted,
  RestrictedAdmin,
  NFT,
  Channel,
  Sub,
  SubAdmin,
  Qualifier,
  QualifierSub,
}
