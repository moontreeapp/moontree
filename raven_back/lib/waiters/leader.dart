import 'package:raven/raven.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  Set<LeaderWallet> backlog = {};

  void init() {
    listen(
      'ciphers.batchedChanges',
      ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          // if this cipher update is in the list of wallets missing ciphers...
          // initialize the wallet and remove it from the list of wallets missing ciphers
          loaded: (loaded) {
            backlog =
                attemptLeaderWalletAddressDerive(change.data.cipherUpdate);
          },
          added: (added) {
            backlog =
                attemptLeaderWalletAddressDerive(change.data.cipherUpdate);
          },
          updated: (updated) {},
          removed: (removed) {},
        );
      },
      autoDeinit: true,
    );

    listen(
      'wallets.changes',
      wallets.changes,
      (Change<Wallet> change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var wallet = added.data;
              if (wallet is LeaderWallet) {
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  services.wallet.leader.deriveMoreAddresses(wallet);
                  services.client.subscribe.toExistingAddresses();
                } else {
                  backlog.add(wallet);
                }
              }
            },
            updated: (updated) {
              /* moved account */
            },
            removed: (removed) {
              // TODO: do we care if this happens? maybe throw an error to track unexpected wallet removal
            });
      },
      autoDeinit: true,
    );

    /// this listener works intandem with address.add listener
    /// (this listener handles some of the cases in which we should
    /// deriveMoreAddresses, and address.dart handles the other cases).
    listen('vouts.changes', vouts.changes, (Change<Vout> change) {
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
                services.client.subscribe.toExistingAddresses();
              } else {
                backlog.add(wallet);
              }
            }
          },
          updated: (updated) {},
          removed: (removed) {});
    });
  }

  Set<LeaderWallet> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <LeaderWallet>{};
    for (var wallet in backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        services.wallet.leader.deriveMoreAddresses(wallet);
      } else {
        ret.add(wallet);
      }
    }
    services.client.subscribe.toExistingAddresses();
    return ret;
  }
}
