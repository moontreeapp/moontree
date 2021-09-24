/// * (raven listener) created account, empty -> create wallet
import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  void init() {
    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    print(cipherRegistry.getLatestCipherType);
    print(passwords.maxPasswordID);
    print(cipherRegistry.currentCipher);
    print('---------0-------');
    listeners.add(accounts.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var account = added.data;
              if (wallets.byAccount.getAll(account.accountId).isEmpty) {
                services.wallets.leaders.makeSaveLeaderWallet(
                    account.accountId, cipherRegistry.currentCipher,
                    cipherUpdate: cipherRegistry.currentCipherUpdate);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    }));
  }
}
