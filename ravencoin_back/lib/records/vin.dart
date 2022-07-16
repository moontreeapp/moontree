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

  /// other possible elements
  // final TxScriptSig? scriptSig;

  Vin(
      {required this.transactionId,
      required this.voutTransactionId,
      required this.voutPosition,
      this.isCoinbase = false});
  @override
  List<Object> get props =>
      [transactionId, voutTransactionId, voutPosition, isCoinbase];

  @override
  String toString() {
    return 'Vin('
        'transactionId: $transactionId, voutTransactionId: $voutTransactionId, voutPosition: $voutPosition, '
        'isCoinbase: $isCoinbase)';
  }

  /// I think the vinId could be the same as voutId, but we'll just make another
  String get id => sha256
      .convert(utf8.encode('$transactionId$voutTransactionId$voutPosition'))
      .toString();

  String get voutId => Vout.getVoutId(voutTransactionId, voutPosition);

  /// having a vin that is a coinbase is an edge case for us,
  /// so in order to preserve simplicity we override the typical values as
  /// coinbase values when necessary.
  String? get coinbase => isCoinbase ? voutTransactionId : null;
  int? get sequence => isCoinbase ? voutPosition : null;
}
