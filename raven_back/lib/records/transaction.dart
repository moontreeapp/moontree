import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';

part 'transaction.g.dart';

@HiveType(typeId: TypeId.Transaction)
class Transaction with EquatableMixin {
  @HiveField(0)
  String addressId;

  @HiveField(1)
  String txId;

  @HiveField(2)
  int height;

  @HiveField(3)
  bool confirmed;

  /// other possible tx elements from transaction.get
  //final String hash;
  //final int version;
  //final int size;
  //final int vsize;
  //final int locktime;
  //final String hex;
  //final String blockhash;
  //final int time;
  //final int blocktime;
  //final int confirmations;
  //// confirmations is
  //// -1 if the transaction is still in the mempool.
  //// 0 if its in the most recent block.
  //// 1 if another block has passed.

  // not from transaction.get
  @HiveField(4)
  String? memo;

  @HiveField(5)
  String note;

  Transaction(
      {required this.addressId,
      required this.txId,
      required this.height,
      required this.confirmed,
      this.memo,
      this.note = ''});

  @override
  List<Object> get props => [
        addressId,
        height,
        confirmed,
        txId,
        memo ?? 'null',
        note,
      ];

  @override
  String toString() {
    return 'Transaction('
        'addressId: $addressId, txId: $txId, height: $height,'
        'confirmed: $confirmed, memo: $memo, note: $note)';
  }

  String get scripthash => addressId;
}
