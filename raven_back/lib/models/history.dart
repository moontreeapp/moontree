import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../records.dart' as records;

class History {
  final String accountId;
  final String walletId;
  final String scripthash;
  final int height;
  final String txHash;
  late int txPos;
  late int value;
  late String ticker;

  History(
      {required this.accountId,
      required this.walletId,
      required this.scripthash,
      required this.height,
      required this.txHash,
      this.txPos = -1,
      this.value = 0,
      this.ticker = ''});

  factory History.fromScripthashHistory(String accountId, String walletId,
      String scripthash, ScripthashHistory history) {
    return History(
      accountId: accountId,
      walletId: walletId,
      scripthash: scripthash,
      height: history.height,
      txHash: history.txHash,
    );
  }

  factory History.fromScripthashUnspent(String accountId, String walletId,
      String scripthash, ScripthashUnspent unspent) {
    return History(
        accountId: accountId,
        walletId: walletId,
        scripthash: scripthash,
        height: unspent.height,
        txHash: unspent.txHash,
        txPos: unspent.txPos,
        value: unspent.value,
        ticker: unspent.ticker ?? '');
  }

  factory History.fromRecord(records.History record) {
    return History(
        accountId: record.accountId,
        walletId: record.walletId,
        scripthash: record.scripthash,
        height: record.height,
        txHash: record.txHash,
        txPos: record.txPos,
        value: record.value,
        ticker: record.ticker);
  }

  records.History toRecord() {
    return records.History(
        accountId: accountId,
        walletId: walletId,
        scripthash: scripthash,
        height: height,
        txHash: txHash,
        txPos: txPos,
        value: value,
        ticker: ticker);
  }
}
