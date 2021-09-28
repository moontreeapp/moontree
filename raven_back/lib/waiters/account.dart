/// * (raven listener) created account, empty -> create wallet
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  void init() {
    subjects.clientAndLogin.stream.listen((clientAndLogin) async {
      if (clientAndLogin.client == null ||
          (services.passwords.passwordRequired &&
              clientAndLogin.login == false)) {
        await deinit();
      } else {
        setupListeners(clientAndLogin.client!);
      }
    });
  }

  void setupListeners(RavenElectrumClient ravenClient) {
    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    if (!listeners.keys.contains('accounts.changes')) {
      listeners['accounts.changes'] =
          accounts.changes.listen((List<Change> changes) {
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
      });
    }
  }
}
