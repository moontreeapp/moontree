import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class LeaderWaiter extends Waiter {
  Set<LeaderWallet> backlogLeaderWallets = {};

  void init() {
    subjects.cipherUpdate.stream.listen((CipherUpdate cipherUpdate) {
      // if this cipher update is in the list of wallets missing ciphers...
      // initialize the wallet and remove it from the list of wallets missing ciphers
      backlogLeaderWallets = attemptLeaderWalletAddressDerive(cipherUpdate);
    });

    listen('wallets.changes', wallets.changes, (List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is LeaderWallet) {
            if (cipherRegistry.ciphers.keys.contains(wallet.cipherUpdate)) {
              // if cipher is available for wallet, use it
              services.wallets.leaders.deriveFirstAddressAndSave(wallet);
            } else {
              // else add it to backlog
              backlogLeaderWallets.add(wallet);
            }
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          addresses.removeAddresses(removed.data);
        });
      });
    });
  }

  Set<LeaderWallet> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <LeaderWallet>{};
    for (var wallet in backlogLeaderWallets) {
      if (wallet.cipherUpdate == cipherUpdate) {
        services.wallets.leaders.deriveFirstAddressAndSave(wallet);
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }
}
