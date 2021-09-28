import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';
import 'package:rxdart/subjects.dart';

// Set<bool> loggedIn = Set();

bool loggedIn = false;

Set<Account> unmatchedAccounts = {};

// class AccountAndCipher {
//   final Account? account;
//   final bool? login; // true

//   AccountAndLogin(this.account, this.login);
// }

class AccountWaiter extends Waiter {
  void init() {
    subjects.login.stream.listen((login) async {
      if (services.passwords.passwordRequired && login == false) {
        await deinit();
      } else {
        setupListeners();
      }
    });
  }

  // if no login
  // add stuff to backlog
  // once login do backlog and erase

  BehaviorSubject loggedInAccountsSubject = BehaviorSubject();

  void setupListeners() {
    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    subjects.login.stream.listen((login) async {
      if (login) {
        loggedIn = true;
        unmatchedAccounts.forEach((account) {
          loggedInAccountsSubject.sink.add(account);
        });
      }
    });

    if (!listeners.keys.contains('accounts.changes')) {
      listeners['accounts.changes'] =
          accounts.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) {
                var account = added.data;

                if (loggedIn) {
                  loggedInAccountsSubject.sink.add(account);
                } else {
                  unmatchedAccounts.add(account);
                }

                // var account = added.data;
                // if (wallets.byAccount.getAll(account.accountId).isEmpty) {
                //   services.wallets.leaders.makeSaveLeaderWallet(
                //       account.accountId, cipherRegistry.currentCipher,
                //       cipherUpdate: cipherRegistry.currentCipherUpdate);
                // }
              },
              updated: (updated) {},
              removed: (removed) {});
        });
      });
    }
  }
}
