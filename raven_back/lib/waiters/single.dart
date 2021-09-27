import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SingleWaiter extends Waiter {
  void init() {
    if (!listeners.keys.contains('wallets.changes')) {
      listeners['wallets.changes'] =
          wallets.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(added: (added) {
            var wallet = added.data;
            if (wallet is SingleWallet && wallet.cipher != null) {
              addresses.save(
                  services.wallets.singles.toAddress(wallet, wallet.cipher!));
              addresses.save(
                  services.wallets.singles.toAddress(wallet, wallet.cipher!));
            }
          }, updated: (updated) {
            /* moved account */
          }, removed: (removed) {
            /* handled by LeadersWaiter*/
          });
        });
      });
    }
  }
}
