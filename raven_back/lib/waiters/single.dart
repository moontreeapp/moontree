import 'package:raven/raven.dart';

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
            backlog =
                attemptSingleWalletAddressDerive(change.data.cipherUpdate);
          },
          added: (added) {
            backlog =
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

  Set<SingleWallet> attemptSingleWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <SingleWallet>{};
    for (var wallet in backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        addresses.save(services.wallet.single.toAddress(wallet));
        addresses.save(services.wallet.single.toAddress(wallet));
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }
}
