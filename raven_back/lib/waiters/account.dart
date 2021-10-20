import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  void init() {
    listen('subjects.cipher', subjects.cipher.stream, (cipher) async {
      if (cipher == services.cipher.currentCipher) {
        backlog.forEach((account) {
          makeFirstWallet(account);
        });
      }
    });

    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    listen('accounts.changes', accounts.changes, (List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              var account = added.data;
              if (services.password.required &&
                  services.cipher.currentCipher == null) {
                backlog.add(account);
              } else {
                makeFirstWallet(account);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    });
  }

  void makeFirstWallet(Account account) {
    if (wallets.byAccount.getAll(account.accountId).isEmpty) {
      services.wallet.leader.makeSaveLeaderWallet(
          account.accountId, services.cipher.currentCipher!,
          cipherUpdate: services.cipher.currentCipherUpdate);
    }
  }
}
