/// * (raven listener) created account, empty -> create wallet
import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/services.dart';

class AccountsWaiter extends Waiter {
  AccountReservoir accounts;
  WalletReservoir wallets;
  LeaderWalletGenerationService leaderWalletGenerationService;

  AccountsWaiter(
      this.accounts, this.wallets, this.leaderWalletGenerationService)
      : super();

  @override
  void init() {
    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    listeners.add(accounts.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var account = added.data;
              if (wallets.byAccount.getAll(account.id).isEmpty) {
                leaderWalletGenerationService.makeAndSaveLeaderWallet(account);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    }));
  }
}
