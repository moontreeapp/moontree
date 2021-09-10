import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart';
import 'package:reservoir/change.dart';
import 'package:sorted_list/sorted_list.dart';

import 'package:raven/account_security_pair.dart';
import 'package:raven/services/service.dart';
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/utils/exceptions.dart';

class BalanceService extends Service {
  late final BalanceReservoir balances;
  late final HistoryReservoir histories;

  BalanceService(this.balances, this.histories) : super();

  /// Get (sum) the balance for an account-security pair
  Balance sumBalance(String accountId, Security security) => Balance(
      accountId: accountId,
      security: security,
      confirmed: histories.byAccount
          .unspents(accountId, security: security)
          .fold(0, (sum, history) => sum + history.value),
      unconfirmed: histories.byAccount
          .unconfirmed(accountId, security: security)
          .fold(0, (sum, history) => sum + history.value));

  /// If there is a change in its history, recalculate a balance. Return a list
  /// of such balances.
  Iterable<Balance> getChangedBalances(List<Change> changes) =>
      uniquePairsFromHistoryChanges(changes)
          .map((pair) => sumBalance(pair.accountId, pair.security));

  /// Same as getChangedBalances, but saves them all as well.
  Future<Iterable<Balance>> saveChangedBalances(List<Change> changes) async {
    var changed = getChangedBalances(changes);
    await balances.saveAll(changed.toList());
    return changed;
  }

  /// Sort in descending order, from largest amount to smallest amount
  List<History> sortedUnspents(String accountId) =>
      histories.byAccount.unspents(accountId).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  /// Asserts that the asset in the account is greater than `amount`
  void assertSufficientFunds(int amount, String accountId,
      {Security security = RVN}) {
    if (balances.getOrZero(accountId, security: security).confirmed < amount) {
      throw InsufficientFunds();
    }
  }

  /// Returns the smallest number of inputs to satisfy the amount
  List<History> collectUTXOs(String accountId, int amount,
      [List<History> except = const []]) {
    assertSufficientFunds(amount, accountId);

    var histories = sortedUnspents(accountId)
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

  /// recalculate balances for all by accountId
  Future calcuSaveBalancesByAccount(String accountId) async {
    // get all securities belonging to account
    // sum balance on each
    // save
    await balances.saveAll([
      for (var security in histories.byAccount
          .getAll(accountId)
          .map((history) => history.security))
        sumBalance(accountId, security)
    ]);
  }

  void removeBalancesByAccount(String accountId) {
    balances.removeAll(balances.byAccount.getAll(accountId));
  }
}
