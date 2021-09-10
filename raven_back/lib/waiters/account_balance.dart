import 'package:reservoir/reservoir.dart';

import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/services/services.dart';

class AccountBalanceWaiter extends Waiter {
  HistoryReservoir histories;
  AccountReservoir accounts;
  WalletReservoir wallets;
  BalanceService balanceService;

  AccountBalanceWaiter(
      this.accounts, this.wallets, this.histories, this.balanceService)
      : super();

  void init() {
    /// new transaction is made / detected
    listeners.add(histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen((List<List<Change>> unflattenedChanges) {
      var changes = unflattenedChanges.expand((change) => change);
      balanceService.saveChangedBalances(changes.toList());
    }));

    /// wallet is moved to or from account
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var wallet = added.data;
              // when wallet added to account recalculate all balances for account.
              balanceService.calcuSaveBalancesByAccount(wallet.accountId);
            },
            updated: (updated) {},
            removed: (removed) {
              var wallet = removed.data;
              // when wallet removed from account recalculate all balances for account.
              balanceService.calcuSaveBalancesByAccount(wallet.accountId);
            });
      });
    }));

    /// account is deleted / created
    listeners.add(accounts.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {},
            updated: (updated) {},
            removed: (removed) {
              // when account is removed remove all balances for that account
              var account = removed.data;
              balanceService.removeBalancesByAccount(account.accountId);
            });
      });
    }));
  }
}
