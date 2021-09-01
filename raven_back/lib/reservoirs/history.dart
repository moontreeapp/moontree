import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'history.keys.dart';

class HistoryReservoir extends Reservoir<_TxHashKey, History> {
  late IndexMultiple<_AccountKey, History> byAccount;
  late IndexMultiple<_WalletKey, History> byWallet;
  late IndexMultiple<_ScripthashKey, History> byScripthash;
  late IndexMultiple<_SecurityKey, History> bySecurity;

  HistoryReservoir([source])
      : super(source ?? HiveSource('histories'), _TxHashKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byScripthash = addIndexMultiple('scripthash', _ScripthashKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
  }

  /// Master overview /////////////////////////////////////////////////////////

  Iterable<History> unspentsByTicker({Security security = RVN}) {
    return bySecurity.getAll(security).where((history) => history.value > 0);
  }

  BalanceRaw balanceByTicker({Security security = RVN}) {
    return unspentsByTicker(security: security).fold(
        BalanceRaw(confirmed: 0, unconfirmed: 0),
        (sum, history) =>
            sum +
            BalanceRaw(
                confirmed: (history.position > -1 ? history.value : 0),
                unconfirmed: history.value));
  }

  /// Account overview ////////////////////////////////////////////////////////
  /// could these be turned into an index?
  /// returns a series of spendable transactions for an account and asset

  Iterable<History> transactionsByAccount(String accountId,
      {Security security = RVN}) {
    return byAccount.getAll(accountId).where((history) =>
        history.confirmed && // not in mempool
        history.security == security);
  }

  Iterable<History> unspentsByAccount(String accountId,
      {Security security = RVN}) {
    return byAccount.getAll(accountId).where((history) =>
        history.value > 0 && // unspent
        history.confirmed && // not in mempool
        history.security == security);
  }

  Iterable<History> unconfirmedByAccount(String accountId,
      {Security security = RVN}) {
    return byAccount.getAll(accountId).where((history) =>
        history.value > 0 && // unspent
        !history.confirmed && // in mempool
        history.security == security);
  }

  /// Wallet overview /////////////////////////////////////////////////////////

  Iterable<History> transactionsByWallet(String walletId,
      {Security security = RVN}) {
    return byWallet.getAll(walletId).where((history) =>
        history.confirmed && // not in mempool
        history.security == security);
  }

  Iterable<History> unspentsByWallet(String walletId,
      {Security security = RVN}) {
    return byWallet.getAll(walletId).where((history) =>
        history.value > 0 && // unspent
        history.confirmed && // not in mempool
        history.security == security);
  }

  Iterable<History> unconfirmedByWallet(String walletId,
      {Security security = RVN}) {
    return byWallet.getAll(walletId).where((history) =>
        history.value > 0 && // unspent
        !history.confirmed && // in mempool
        history.security == security);
  }

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}
