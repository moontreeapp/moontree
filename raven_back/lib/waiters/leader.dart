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

    listen('wallets.batchedChanges', wallets.batchedChanges,
        (List<Change<Wallet>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var wallet = added.data;
              if (wallet is LeaderWallet) {
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  services.wallet.leader.deriveMoreAddresses(wallet);
                } else {
                  backlogLeaderWallets.add(wallet);
                }
              }
            },
            updated: (updated) {
              /* moved account */
            },
            removed: (removed) {
              // TODO: do we care if this happens? maybe throw an error to track unexpected wallet removal
            });
      });
    });

    /// this listener works intandem with address.add listener
    /// (this listener handles some of the cases in which we should
    /// deriveMoreAddresses, and address.dart handles the other cases).
    listen('vouts.batchedChanges', vouts.batchedChanges,
        (List<Change<Vout>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var vout = added.data;
              if (vout.wallet is LeaderWallet) {
                var wallet = vout.wallet as LeaderWallet;
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  services.wallet.leader.deriveMoreAddresses(
                    wallet,
                    exposures: [vout.address!.exposure],
                  );
                } else {
                  backlogLeaderWallets.add(wallet);
                }
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    });
  }

  Set<LeaderWallet> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <LeaderWallet>{};
    for (var wallet in backlogLeaderWallets) {
      if (wallet.cipherUpdate == cipherUpdate) {
        services.wallet.leader.deriveMoreAddresses(wallet);
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }
}
