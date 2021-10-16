import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/raven.dart';

import '_type_id.dart';

part 'vin.g.dart';

@HiveType(typeId: TypeId.Vin)
class Vin with EquatableMixin {
  @HiveField(0)
  String txId;

  @HiveField(1)
  String voutTxId;

  @HiveField(2)
  int voutPosition;

  /// other possible elements
  // final String? coinbase;
  // final int? sequence;
  // final TxScriptSig? scriptSig;

  Vin({required this.txId, required this.voutTxId, required this.voutPosition});

  @override
  List<Object> get props => [txId, voutTxId, voutPosition];

  @override
  String toString() {
    return 'Vin('
        'txId: $txId, voutTxId: $voutTxId, voutPosition: $voutPosition)';
  }

  /// I think the vinId could be the same as voutId, but we'll just make another
  String get vinId =>
      sha256.convert(utf8.encode('$txId$voutTxId$voutPosition')).toString();

  String get voutId => Vout.getVoutId(voutTxId, voutPosition);
}
