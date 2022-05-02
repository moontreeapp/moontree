import 'package:raven_back/raven_back.dart';

import 'waiter.dart';

class SingleWaiter extends Waiter {
  Set<SingleWallet> backlog = {};

  void init() {
    listen(
      'ciphers.changes',
      res.ciphers.changes,
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
                print('SAVING ADDRESS FOR SINGLE WALLET IMMEDIATELY');
                res.addresses.save(
                    services.wallet.single.toAddress(wallet as SingleWallet));
              } else {
                backlog.add(wallet as SingleWallet);
              }
            },
            updated: (updated) {
              /* never happens */
            },
            removed: (removed) {
              /* handled by LeadersWaiter*/
            });
      },
    );
  }

  void attemptSingleWalletAddressDerive(CipherUpdate cipherUpdate) {
    var remove = <SingleWallet>{};
    for (var wallet in backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        print('SAVING ADDRESS FOR SINGLE WALLET IN BACKLOG');
        res.addresses.save(services.wallet.single.toAddress(wallet));
        remove.add(wallet);
      }
    }
    for (var wallet in remove) {
      backlog.remove(wallet);
    }
  }
}
