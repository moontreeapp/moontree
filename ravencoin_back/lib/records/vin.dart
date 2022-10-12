import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

import '_type_id.dart';

part 'vin.g.dart';

@HiveType(typeId: TypeId.Vin)
class Vin with EquatableMixin {
  @HiveField(0)
  String transactionId;

  /// all pertinent values are on vouts. so vins point to vouts.

  @HiveField(1)
  String voutTransactionId;

  @HiveField(2)
  int voutPosition;

  @HiveField(3)
  bool isCoinbase;

  @HiveField(4, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(5, defaultValue: Net.Main)
  final Net net;

  /// other possible elements
  // final TxScriptSig? scriptSig;

  Vin({
    required this.transactionId,
    required this.voutTransactionId,
    required this.voutPosition,
    this.isCoinbase = false,
    required this.chain,
    required this.net,
  });
  @override
  List<Object> get props => [
        transactionId,
        voutTransactionId,
        voutPosition,
        isCoinbase,
        chain,
        net,
      ];

  @override
  String toString() => 'Vin(transactionId: $transactionId, voutTransactionId: '
      '$voutTransactionId, voutPosition: $voutPosition, isCoinbase: '
      '$isCoinbase, ${chainNetReadable(chain, net)})';

  /// I think the vinId could be the same as voutId, but we'll just make another
  //String get id => sha256
  //    .convert(utf8.encode('$transactionId$voutTransactionId$voutPosition'))
  //    .toString();

  /// not sure why we were hashing the data, rather than making a composit key.
  /// so I'll just make an additional idKey like we did for address now that we
  /// also want to include chain and net.
  String get id =>
      key(transactionId, voutTransactionId, voutPosition, chain, net);

  static String key(String transactionId, String voutTransactionId,
          int voutPosition, Chain chain, Net net) =>
      '$transactionId:$voutTransactionId:$voutPosition:${chainNetKey(chain, net)}';

  String get voutId => Vout.key(voutTransactionId, voutPosition, chain, net);

  /// having a vin that is a coinbase is an edge case for us,
  /// so in order to preserve simplicity we override the typical values as
  /// coinbase values when necessary.
  String? get coinbase => isCoinbase ? voutTransactionId : null;
  int? get sequence => isCoinbase ? voutPosition : null;
}
