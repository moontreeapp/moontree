import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/models/history.dart';
import 'package:raven/records.dart' as records;

class HistoryReservoir extends Reservoir<String, records.History, History> {
  late MultipleIndex<String, History> byAccount;
  late MultipleIndex<String, History> byWallet;
  late MultipleIndex<String, History> byScripthash;
  late MultipleIndex<String, History> byTicker;

  HistoryReservoir() : super(HiveSource('histories')) {
    addPrimaryIndex((histories) => histories.txHash);

    byAccount = addMultipleIndex('account', (history) => history.accountId);
    byWallet = addMultipleIndex('wallet', (history) => history.walletId);
    byScripthash =
        addMultipleIndex('scripthash', (history) => history.scripthash);
    byTicker = addMultipleIndex('ticker', (history) => history.ticker);
  }

  /// could this be turned into an index?
  /// returns a series of spendable transactions for an account and asset
  Iterable<History>? unspentsByAccount(String accountId, {String ticker = ''}) {
    return byAccount.getAll(accountId).where((element) =>
        element.value > 0 && // unspent
        element.txPos > -1 && // not in mempool
        element.ticker == ticker); // rvn default
  }

  Iterable<History>? unconfirmedByAccount(String accountId,
      {String ticker = ''}) {
    return byAccount.getAll(accountId).where((element) =>
        element.value > 0 && // unspent
        element.txPos == -1 && // not in mempool
        element.ticker == ticker); // rvn default
  }

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
