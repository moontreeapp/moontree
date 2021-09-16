/// * (raven listener) created account, empty -> create wallet
import 'package:reservoir/reservoir.dart';

import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/services/services.dart';

class AccountsWaiter extends Waiter {
  AccountReservoir accounts;
  WalletReservoir wallets;
  LeaderWalletGenerationService leaderWalletGenerationService;

  AccountsWaiter(
      this.accounts, this.wallets, this.leaderWalletGenerationService)
      : super();

  void init() {
    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    listeners.add(accounts.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var account = added.data;
              if (wallets.byAccount.getAll(account.accountId).isEmpty) {
                leaderWalletGenerationService
                    .makeSaveLeaderWallet(account.accountId);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    }));
  }
}
