import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

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
  String get assetId => symbol;

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
  bool get hasIpfs =>
      metadata != '' &&
      metadata.contains(RegExp(
          r'Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,}'));

  bool get hasMetadata => metadata != '';
  bool get isMaster => symbol.endsWith('!');
  String get nonMasterSymbol => symbol.replaceAll('!', '');
  String get masterSymbol => nonMasterSymbol + '!';
}
