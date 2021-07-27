import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../records.dart' as records;

class Report {
  records.Report record;

  Report(scripthash, balance, history, unspent)
      : record = records.Report(scripthash, balance, history, unspent);

  String get scripthash => record.scripthash;

  ScripthashBalance get balance => record.balance;

  ScripthashHistory get history => record.history;

  ScripthashUnspent get unspent => record.unspent;

  factory Report.fromRecord(records.Report record) {
    return Report(
        record.scripthash, record.balance, record.history, record.unspent);
  }

  records.Report toRecord() {
    return record;
  }
}
