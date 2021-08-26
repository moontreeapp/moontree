import 'package:collection/collection.dart';
import 'package:reservoir/change.dart';
import 'package:sorted_list/sorted_list.dart';

import 'package:raven/services/service.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/utils/exceptions.dart';

class BalanceService extends Service {
  late final BalanceReservoir balances;
  late final HistoryReservoir histories;

  BalanceService(this.balances, this.histories) : super();

  // runs it for affected account-security combinations
  void calcuSaveBalance(List<Change> changes) {
    var uniquePairs = [];
    changes.forEach((Change change) {
      History history = change.data;
      if (!uniquePairs.contains([history.accountId, history.security])) {
        uniquePairs.add([history.accountId, history.security]);
      }
    });
    print('uniquePairs'); // account 0 rvn, account 0 magicmusk
    print(uniquePairs); // account 0 rvn, account 0 magicmusk
    for (var accountIdSecurity in uniquePairs) {
      saveBalance(accountIdSecurity[0], accountIdSecurity[1]);
    }
  }

  void saveBalance(String accountId, Security security) {
    balances.save(Balance(
        accountId: accountId,
        security: security,
        confirmed: histories
            .unspentsByAccount(accountId, security: security)
            .fold(0, (sum, history) => sum + history.value),
        unconfirmed: histories
            .unconfirmedByAccount(accountId, security: security)
            .fold(0, (sum, history) => sum + history.value)));
  }

  // runs it for all  and all security
  void recalculateBalance(_changes) {
    if (_changes.length == 0) {
      return;
    }
    for (var accountId in histories.byAccount.keys) {
      var hists = histories.byAccount.getAll([accountId]);

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
            accountId: accountId as String,
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
