import 'package:raven_back/raven_back.dart';

import 'waiter.dart';

class SingleWaiter extends Waiter {
  Set<SingleWallet> backlog = {};

  void init() {
    listen(
      'ciphers.changes',
      ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          // if this cipher update is in the list of wallets missing ciphers...
          // initialize the wallet and remove it from the list of wallets missing ciphers
          loaded: (loaded) {
            attemptSingleWalletAddressDerive(change.data.cipherUpdate);
          },
          added: (added) {
            attemptSingleWalletAddressDerive(change.data.cipherUpdate);
          },
          updated: (updated) {},
          removed: (removed) {},
        );
      },
      autoDeinit: true,
    );

    listen(
      'streams.wallet.singleChanges',
      streams.wallet.singleChanges,
      (Change<Wallet> change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var wallet = added.data;
              if (wallet.cipher != null) {
                addresses.save(
                    services.wallet.single.toAddress(wallet as SingleWallet));
                addresses.save(services.wallet.single.toAddress(wallet));
              } else {
                backlog.add(wallet as SingleWallet);
              }
            },
            updated: (updated) {
              /* moved account */
            },
            removed: (removed) {
              /* handled by LeadersWaiter*/
            });
      },
      autoDeinit: true,
    );
  }

  void attemptSingleWalletAddressDerive(CipherUpdate cipherUpdate) {
    var remove = <SingleWallet>{};
    for (var wallet in backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        // why is this happening twice?
        addresses.save(services.wallet.single.toAddress(wallet));
        addresses.save(services.wallet.single.toAddress(wallet));
        remove.add(wallet);
      }
    }
    // subscribe to the addresses we just created
    services.client.subscribe.toExistingAddresses();
    for (var wallet in remove) {
      backlog.remove(wallet);
    }
  }
}
