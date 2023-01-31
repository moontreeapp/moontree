import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:moontree_utils/extensions/bytedata.dart';
import 'package:wallet_utils/wallet_utils.dart';

import 'package:client_back/records/_type_id.dart';

part 'balance_view.g.dart';

@HiveType(typeId: TypeId.BalanceView)
class BalanceViewRecord with EquatableMixin {
  /* database ids */

  @HiveField(0)
  final int? serverId;

  @HiveField(1)
  final String? error;

  /* other ids */

  @HiveField(2)
  final String? chainName;

  @HiveField(2)
  final String walletId;

  /* data */

  @HiveField(3)
  final String symbol;

  @HiveField(6)
  final int sats;

  BalanceViewRecord({
    this.serverId,
    this.voutId = -1,
    this.verifierStringVoutId,
    required this.symbol,
    required this.chain,
    required this.net,
    required this.totalSupply,
    required this.divisibility,
    required this.reissuable,
    required this.frozen,
    required this.associatedData,
  }) {
    symbolSymbol = Symbol(symbol)(chain, net);
  }

  late Symbol symbolSymbol;

  @override
  List<Object?> get props => <Object?>[
        serverId,
        voutId,
        verifierStringVoutId,
        symbol,
        chain,
        net,
        totalSupply,
        divisibility,
        reissuable,
        frozen,
        associatedData,
      ];

  @override
  String toString() => 'BalanceViewRecord('
      'serverId: $serverId, voutId: $voutId, verifierStringVoutId: $verifierStringVoutId, '
      'symbol: $symbol, ${ChainNet(chain, net).readable},'
      'totalSupply: $totalSupply, divisibility: $divisibility, '
      'reissuable: $reissuable, frozen: $frozen, '
      'associatedData: $associatedData)';

  factory BalanceViewRecord.from(
    BalanceViewRecord record, {
    int? serverId,
    int? voutId,
    int? verifierStringVoutId,
    String? symbol,
    Chain? chain,
    Net? net,
    int? totalSupply,
    int? divisibility,
    bool? reissuable,
    bool? frozen,
    ByteData? associatedData,
  }) =>
      BalanceViewRecord(
        serverId: serverId ?? record.serverId,
        verifierStringVoutId:
            verifierStringVoutId ?? record.verifierStringVoutId,
        voutId: voutId ?? record.voutId,
        symbol: symbol ?? (chain != null ? chain.symbol : record.symbol),
        chain: chain ?? record.chain,
        net: net ?? record.net,
        totalSupply: totalSupply ?? record.totalSupply,
        divisibility: divisibility ?? record.divisibility,
        reissuable: reissuable ?? record.reissuable,
        associatedData: associatedData ?? record.associatedData,
        frozen: frozen ?? record.frozen,
      );

  String get metadata => associatedData.toBs58();

  @HiveField(4)
  final Chain chain;

  @HiveField(5)
  final Net net;

  /// about asset
  bool get hasData => metadata.isAssetData;
  String? get data => hasData ? metadata : null;
  bool get hasMetadata => metadata != '';
  double get amount => totalSupply.asCoin;

  /// key stuff
  static String key(String symbol, Chain chain, Net net) =>
      '$symbol:${ChainNet(chain, net).key}';
  String get id => key(symbol, chain, net);
  String? get parentId => symbolSymbol.parentSymbol == null
      ? null
      : key(symbolSymbol.parentSymbol!, chain, net);

  /// bringing symbol values to top level
  SymbolType get symbolType => symbolSymbol.symbolType;
  String get symbolTypeName => symbolSymbol.symbolTypeName;
  String get baseSymbol => symbolSymbol.baseSymbol;
  String get baseSubSymbol => symbolSymbol.baseSubSymbol;
  bool get isAdmin => symbolSymbol.isAdmin;
  bool get isSubAdmin => symbolSymbol.isSubAdmin;
  bool get isQualifier => symbolSymbol.isQualifier;
  bool get isAnySub => symbolSymbol.isAnySub;
  bool get isRestricted => symbolSymbol.isRestricted;
  bool get isMain => symbolSymbol.isMain;
  bool get isNFT => symbolSymbol.isNFT;
  bool get isChannel => symbolSymbol.isChannel;
}
