import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:date_format/date_format.dart';

import '_type_id.dart';

part 'transaction.g.dart';

@HiveType(typeId: TypeId.Transaction)
class Transaction with EquatableMixin {
  @HiveField(0)
  String txId;

  @HiveField(1)
  int height;

  @HiveField(2)
  bool confirmed;

  @HiveField(3)
  int time;

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
      {required this.txId,
      required this.height,
      required this.confirmed,
      required this.time,
      this.memo,
      this.note = ''});

  @override
  List<Object> get props => [
        height,
        confirmed,
        time,
        txId,
        memo ?? 'null',
        note,
      ];

  @override
  String toString() {
    return 'Transaction('
        'txId: $txId, height: $height, confirmed: $confirmed, time: $time, '
        'memo: $memo, note: $note)';
  }

  // could belong on frontend...
  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(time * 1000);
  String get formattedDatetime =>
      formatDate(datetime, [MM, ' ', d, ', ', yyyy]);
}
