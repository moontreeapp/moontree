import 'package:raven/records.dart' as records;
import 'package:raven/models/balance.dart';
import 'package:raven/models/history.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

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

  /// Master overview /////////////////////////////////////////////////////////

  Iterable<History> unspentsByTicker({String ticker = ''}) {
    return byTicker.getAll(ticker).where((history) => history.value > 0);
  }

  Balance balanceByTicker({String ticker = ''}) {
    return unspentsByTicker(ticker: ticker).fold(
        Balance(confirmed: 0, unconfirmed: 0),
        (sum, history) =>
            sum +
            Balance(
                confirmed: (history.txPos > -1 ? history.value : 0),
                unconfirmed: history.value));
  }

  /// Account overview ////////////////////////////////////////////////////////
  /// could these be turned into an index?
  /// returns a series of spendable transactions for an account and asset

  Iterable<History> transactionsByAccount(String accountId,
      {String ticker = ''}) {
    return byAccount.getAll(accountId).where((history) =>
        history.txPos > -1 && // not in mempool
        history.ticker == ticker); // rvn default
  }

  Iterable<History> unspentsByAccount(String accountId, {String ticker = ''}) {
    return byAccount.getAll(accountId).where((history) =>
        history.value > 0 && // unspent
        history.txPos > -1 && // not in mempool
        history.ticker == ticker); // rvn default
  }

  Iterable<History> unconfirmedByAccount(String accountId,
      {String ticker = ''}) {
    return byAccount.getAll(accountId).where((history) =>
        history.value > 0 && // unspent
        history.txPos == -1 && // in mempool
        history.ticker == ticker); // rvn default
  }

  /// Wallet overview /////////////////////////////////////////////////////////

  Iterable<History> transactionsByWallet(String walletId,
      {String ticker = ''}) {
    return byWallet.getAll(walletId).where((history) =>
        history.txPos > -1 && // not in mempool
        history.ticker == ticker); // rvn default
  }

  Iterable<History> unspentsByWallet(String walletId, {String ticker = ''}) {
    return byWallet.getAll(walletId).where((history) =>
        history.value > 0 && // unspent
        history.txPos > -1 && // not in mempool
        history.ticker == ticker); // rvn default
  }

  Iterable<History> unconfirmedByWallet(String walletId, {String ticker = ''}) {
    return byWallet.getAll(walletId).where((history) =>
        history.value > 0 && // unspent
        history.txPos == -1 && // in mempool
        history.ticker == ticker); // rvn default
  }

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
