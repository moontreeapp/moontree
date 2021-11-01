import 'package:raven/records/cipher.dart';
import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  void init() {
    listen('ciphers.changes', ciphers.changes, (Change<Cipher> change) async {
      if (change is Added) {
        if (change.data.cipher == services.cipher.currentCipher) {
          backlog.forEach((account) {
            services.account
                .makeFirstWallet(account, services.cipher.currentCipherBase!);
          });
        }
      }
    });

    /// this listener implies we have to load everything backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    listen<Change<Account>>('accounts.changes', accounts.changes, (change) {
      if (change is Added) {
        var account = change.data;
        if (services.cipher.currentCipher == null) {
          backlog.add(account);
        } else {
          services.account
              .makeFirstWallet(account, services.cipher.currentCipherBase!);
        }
      }
    });
  }
}
