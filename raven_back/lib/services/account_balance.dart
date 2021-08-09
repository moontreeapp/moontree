import 'dart:async';

import 'package:collection/collection.dart';

import 'package:raven/models.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/balance.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/utils/exceptions.dart';
import 'package:sorted_list/sorted_list.dart';

class AccountBalanceService extends Service {
  AccountReservoir accounts;
  BalanceReservoir balances;
  HistoryReservoir histories;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceService(this.accounts, this.balances, this.histories) : super();

  @override
  void init() {
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(calculateBalance);
  }

  @override
  void deinit() {
    listener.cancel();
  }

  // runs it for affected account-security combinations
  void calculateBalance(changes) {
    var combos = [];
    changes.forEach((History history) {
      if (!combos.contains([history.accountId, history.security])) {
        combos.add([history.accountId, history.security]);
      }
    });
    for (var accountIdSecurity in combos) {
      var accountId = accountIdSecurity[0];
      var security = accountIdSecurity[1];
      balances.save(Balance(
          accountId: accountId,
          security: security,
          confirmed: histories
                  .unspentsByAccount(accountId, security: security)
                  .fold(0, (sum, history) => sum ?? 0 + history.value) ??
              0,
          unconfirmed: histories
                  .unconfirmedByAccount(accountId, security: security)
                  .fold(0, (sum, history) => sum ?? 0 + history.value) ??
              0));
    }
  }

  // runs it for all accounts and all security
  void recalculateBalance(_changes) {
    if (_changes.length == 0) {
      return;
    }
    for (var accountId in histories.byAccount.keys) {
      var hists = histories.byAccount.getAll(accountId);

      var balanceBySecurity = hists
          .groupFoldBy((History history) => history.security,
              (BalanceRaw? previous, History history) {
        var balance = previous ?? BalanceRaw(confirmed: 0, unconfirmed: 0);
        return BalanceRaw(
            confirmed:
                balance.confirmed + (history.txPos > -1 ? history.value : 0),
            unconfirmed: balance.unconfirmed +
                (history.txPos == -1 ? history.value : 0));
      });

      balanceBySecurity.forEach((security, bal) {
        var balance = Balance(
            accountId: accountId,
            security: security,
            confirmed: bal.confirmed,
            unconfirmed: bal.unconfirmed);
        balances.save(balance);
      });
    }
  }

  SortedList<History> sortedUTXOs(String accountId) {
    var sortedList = SortedList<History>(
        (History a, History b) => a.value.compareTo(b.value));
    sortedList.addAll(histories.unspentsByAccount(accountId));
    return sortedList;
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<History> collectUTXOs(String accountId, int amount,
      [List<History>? except]) {
    var ret = <History>[];
    var balance = balances.getRVN(accountId);
    if (balance.confirmed < amount) {
      throw InsufficientFunds();
    }
    var utxos = sortedUTXOs(accountId);
    utxos.removeWhere((utxo) => (except ?? []).contains(utxo));
    /* can we find an ideal singular utxo? */
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].value >= amount) {
        return [utxos[i]];
      }
    }
    /* what combinations of utxo's must we return?
    lets start by grabbing the largest one
    because we know we can consume it all without producing change...
    and lets see how many times we can do that */
    var remainder = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remainder < utxos[i].value) {
        break;
      }
      ret.add(utxos[i]);
      remainder = (remainder - utxos[i].value).toInt();
    }
    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
    return ret;
  }
}
