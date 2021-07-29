import 'package:raven/services/address_subscription.dart';

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

  factory History.fromRowAndIndex(ScripthashRow row, int index) {
    var newTxPos;
    var newValue;
    for (var unspent in row.unspent) {
      if (row.history[index].height == unspent.height &&
          row.history[index].txHash == unspent.txHash) {
        newTxPos = unspent.txPos;
        newValue = unspent.value;
      }
    }
    return History(row.address.accountId, row.address.scripthash,
        row.history[index].height, row.history[index].txHash,
        txPos: newTxPos, value: newValue);
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
