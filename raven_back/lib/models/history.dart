import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../records.dart' as records;

class History {
  final String accountId;
  final String scripthash;
  final int height;
  final String txHash;
  late int? txPos;
  late int? value;

  History(this.accountId, this.scripthash, this.height, this.txHash,
      {this.txPos, this.value});

  factory History.fromScripthashHistory(
      String accountId, String scripthash, ScripthashHistory history) {
    return History(
      accountId,
      scripthash,
      history.height,
      history.txHash,
    );
  }

  factory History.fromScripthashUnspent(
      String accountId, String scripthash, ScripthashUnspent unspent) {
    return History(accountId, scripthash, unspent.height, unspent.txHash,
        txPos: unspent.txPos, value: unspent.value);
  }

  factory History.fromRecord(records.History record) {
    return History(
        record.accountId, record.scripthash, record.height, record.txHash,
        txPos: record.txPos, value: record.value);
  }

  records.History toRecord() {
    return records.History(accountId, scripthash, height, txHash,
        txPos: txPos, value: value);
  }
}
