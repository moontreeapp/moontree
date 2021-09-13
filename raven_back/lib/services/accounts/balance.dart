import 'package:reservoir/change.dart';

import 'package:raven/utils/account_security_pair.dart';
import 'package:raven/services/service.dart';
import 'package:raven/records/records.dart';
import 'package:raven/joins.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/utils/exceptions.dart';

class BalanceService extends Service {
  late final BalanceReservoir balances;
  late final HistoryReservoir histories;

  BalanceService(this.balances, this.histories) : super();

  /// Listener Logic //////////////////////////////////////////////////////////

  /// Get (sum) the balance for an account-security pair
  Balance sumBalance(Wallet wallet, Security security) => Balance(
      walletId: wallet.walletId,
      security: security,
      confirmed: HistoryReservoir.whereUnspent(
              given: wallet.histories, security: security)
          .fold(0, (sum, history) => sum + history.value),
      unconfirmed: HistoryReservoir.whereUnconfirmed(
              given: wallet.histories, security: security)
          .fold(0, (sum, history) => sum + history.value));

  /// If there is a change in its history, recalculate a balance. Return a list
  /// of such balances.
  Iterable<Balance> getChangedBalances(List<Change> changes) =>
      uniquePairsFromHistoryChanges(changes)
          .map((pair) => sumBalance(pair.wallet, pair.security));

  /// Same as getChangedBalances, but saves them all as well.
  Future<Iterable<Balance>> saveChangedBalances(List<Change> changes) async {
    var changed = getChangedBalances(changes);
    await balances.saveAll(changed.toList());
    return changed;
  }

  /// Transaction Logic ///////////////////////////////////////////////////////

  /// Sort in descending order, from largest amount to smallest amount
  List<History> sortedUnspents(Account account) =>
      HistoryReservoir.whereUnspent(given: account.histories).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  /// Asserts that the asset in the account is greater than `amount`
  void assertSufficientFunds(int amount, String accountId,
      {Security security = RVN}) {
    if (balances.getOrZero(accountId, security: security).confirmed < amount) {
      throw InsufficientFunds();
    }
  }

  /// Returns the smallest number of inputs to satisfy the amount
  List<History> collectUTXOs(Account account, int amount,
      [List<History> except = const []]) {
    assertSufficientFunds(amount, account.accountId);

    var histories = sortedUnspents(account)
      ..removeWhere((utxo) => except.contains(utxo));

    // Can we find a single, ideal UTXO by searching from smallest to largest?
    for (var history in histories.reversed) {
      if (history.value >= amount) return [history];
    }

    // Otherwise, satisfy the amount by combining UTXOs from largest to smallest
    var collection = <History>[];
    var remaining = amount;
    for (var history in histories) {
      if (remaining > 0) collection.add(history);
      if (remaining < history.value) break;
      remaining -= history.value;
    }

    return collection;
  }

  /// Wallet Aggregation Logic ////////////////////////////////////////////////

  List<Balance> accountBalances(Account account) {
    // ignore: omit_local_variable_types
    Map<Security, Balance> balancesBySecurity = {};
    for (var balance in account.balances) {
      if (!balancesBySecurity.containsKey(balance.security)) {
        balancesBySecurity[balance.security] = balance;
      } else {
        balancesBySecurity[balance.security] =
            balancesBySecurity[balance.security]! + balance;
      }
    }
    return balancesBySecurity.values.toList();
  }

  Balance accountBalance(Account account, Security security) {
    var retBalance =
        Balance(walletId: '', confirmed: 0, unconfirmed: 0, security: security);
    for (var balance in account.balances) {
      if (balance.security == security) {
        retBalance = retBalance + balance;
      }
    }
    return retBalance;
  }

  List<Balance> walletBalances(Wallet wallet) {
    // ignore: omit_local_variable_types
    Map<Security, Balance> balancesBySecurity = {};
    for (var balance in wallet.balances) {
      if (!balancesBySecurity.containsKey(balance.security)) {
        balancesBySecurity[balance.security] = balance;
      } else {
        balancesBySecurity[balance.security] =
            balancesBySecurity[balance.security]! + balance;
      }
    }
    return balancesBySecurity.values.toList();
  }

  Balance walletBalance(Wallet wallet, Security security) {
    var retBalance =
        Balance(walletId: '', confirmed: 0, unconfirmed: 0, security: security);
    for (var balance in wallet.balances) {
      if (balance.security == security) {
        retBalance = retBalance + balance;
      }
    }
    return retBalance;
  }
}
