import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class LeaderWaiter extends Waiter {
  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is LeaderWallet && wallet.cipher != null) {
            services.wallets.leaders
                .deriveFirstAddressAndSave(wallet, wallet.cipher!);
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          addresses.removeAddresses(removed.data);
        });
      });
    }));
  }
}
