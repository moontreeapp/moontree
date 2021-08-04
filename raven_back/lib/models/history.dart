import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../records.dart' as records;

class History {
  final String walletId;
  final String scripthash;
  final int height;
  final String txHash;
  late int? txPos;
  late int? value;

  History(
      {required this.walletId,
      required this.scripthash,
      required this.height,
      required this.txHash,
      this.txPos,
      this.value});

  factory History.fromScripthashHistory(
      String walletId, String scripthash, ScripthashHistory history) {
    return History(
      walletId: walletId,
      scripthash: scripthash,
      height: history.height,
      txHash: history.txHash,
    );
  }

  factory History.fromScripthashUnspent(
      String walletId, String scripthash, ScripthashUnspent unspent) {
    return History(
        walletId: walletId,
        scripthash: scripthash,
        height: unspent.height,
        txHash: unspent.txHash,
        txPos: unspent.txPos,
        value: unspent.value);
  }

  factory History.fromRecord(records.History record) {
    return History(
        walletId: record.walletId,
        scripthash: record.scripthash,
        height: record.height,
        txHash: record.txHash,
        txPos: record.txPos,
        value: record.value);
  }

  records.History toRecord() {
    return records.History(
        walletId: walletId,
        scripthash: scripthash,
        height: height,
        txHash: txHash,
        txPos: txPos,
        value: value);
  }
}
