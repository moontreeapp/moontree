import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  void init() {
    subjects.cipher.stream.listen((cipher) async {
      if (cipher == cipherRegistry.currentCipher) {
        if (backlog.isNotEmpty) {
          backlog.forEach((account) {
            makeFirstWallet(account);
          });
        }
      }
    });

    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    if (!listeners.keys.contains('accounts.changes')) {
      listeners['accounts.changes'] =
          accounts.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) {
                var account = added.data;
                if (cipherRegistry.currentCipher == null) {
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
  }

  void makeFirstWallet(Account account) {
    if (wallets.byAccount.getAll(account.accountId).isEmpty) {
      services.wallets.leaders.makeSaveLeaderWallet(
          account.accountId, cipherRegistry.currentCipher!,
          cipherUpdate: cipherRegistry.currentCipherUpdate);
    }
  }
}
