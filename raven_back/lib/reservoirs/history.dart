import 'package:ordered_set/ordered_set.dart';

import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/models/history.dart';
import 'package:raven/records.dart' as records;

class HistoryReservoir extends Reservoir<String, records.History, History> {
  late MultipleIndex<String, History> byAccount;
  late MultipleIndex<String, History> byWallet;
  late MultipleIndex<String, History> byScripthash;

  HistoryReservoir() : super(HiveSource('histories')) {
    addPrimaryIndex((histories) => histories.txHash);

    byAccount = addMultipleIndex('account', (history) => history.accountId);
    byWallet = addMultipleIndex('wallet', (history) => history.walletId);
    byScripthash =
        addMultipleIndex('scripthash', (history) => history.scripthash);
  }

  /// returns account addresses in order
  Iterable<History>? unspentsByAccount(String accountId) {
    return byAccount
        .getAll(accountId)
        .where((element) => element.txPos != null);
  }

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
