import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SingleWaiter extends Waiter {
  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is SingleWallet) {
            addresses.save(services.wallets.singles.toAddress(
                wallet, cipherRegistry.ciphers[wallet.cipherUpdate]!));
            addresses.save(services.wallets.singles.toAddress(
                wallet, cipherRegistry.ciphers[wallet.cipherUpdate]!));
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          /* handled by LeadersWaiter*/
        });
      });
    }));
  }
}
