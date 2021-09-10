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

    /// I'm not sure having a balance reservoir is even a good idea,
    /// to keep it in sync we have to recalculate the every balance in the reservoir each time we move a wallet to an account...
    /// wallet is moved to or from account - NEEDS TESTING
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {},
            updated: (updated) {
              var wallet = updated.data;
              // when wallet added to account recalculate all balances for account.
              // if wallet.accountId changed...
              // can't tell what it changed from so we might as well recalculate for all accounts.
              for (var account in accounts.data) {
                balanceService.removeBalancesByAccount(account.accountId);
              }
              for (var account in accounts.data) {
                balanceService.calcuSaveBalancesByAccount(account.accountId);
              }
            },
            removed: (removed) {});
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
