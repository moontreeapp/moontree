import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:date_format/date_format.dart';
import 'package:ravencoin_back/records/types/chain.dart';
import 'package:ravencoin_back/records/types/net.dart';

import '_type_id.dart';

part 'transaction.g.dart';

@HiveType(typeId: TypeId.Transaction)
class Transaction with EquatableMixin {
  @HiveField(0)
  String id;

  @HiveField(1)
  bool confirmed;

  @HiveField(2)
  int? time;

  @HiveField(3)
  int? height;

  @HiveField(4, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(5, defaultValue: Net.Main)
  final Net net;

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

  Transaction({
    required this.id,
    required this.confirmed,
    this.time,
    this.height,
    required this.chain,
    required this.net,
  });

  @override
  List<Object?> get props => [
        height,
        confirmed,
        time,
        id,
        chain,
        net,
      ];

  @override
  String toString() {
    return 'Transaction('
        'id: $id, height: $height, confirmed: $confirmed, time: $time, '
        '${chainNetReadable(chain, net)})';
  }

  // technically belongs on frontend...
  DateTime get datetime =>
      DateTime.fromMillisecondsSinceEpoch((time ?? 0) * 1000);

  String get formattedDatetime => time != null
      ? formatDate(datetime, [MM, ' ', d, ', ', yyyy])
      : 'In Transit';

  String get idKey => key(id, chain, net);

  static String key(String id, Chain chain, Net net) =>
      '$id:${chainNetKey(chain, net)}';
}
