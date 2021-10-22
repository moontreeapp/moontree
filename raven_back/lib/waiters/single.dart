import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class SingleWaiter extends Waiter {
  Set<SingleWallet> backlog = {};

  void init() {
    if (!listeners.keys.contains('subjects.cipherUpdate')) {
      listeners['subjects.cipherUpdate'] =
          subjects.cipherUpdate.stream.listen((CipherUpdate cipherUpdate) {
        backlog = attemptSingleWalletAddressDerive(cipherUpdate);
      });

      if (!listeners.keys.contains('wallets.batchedChanges')) {
        listeners['wallets.batchedChanges'] = wallets.batchedChanges
            .listen((List<Change<Wallet>> batchedChanges) {
          batchedChanges.forEach((change) {
            change.when(added: (added) {
              var wallet = added.data;
              if (wallet is SingleWallet) {
                if (wallet.cipher != null) {
                  addresses.save(services.wallet.single.toAddress(wallet));
                  addresses.save(services.wallet.single.toAddress(wallet));
                } else {
                  backlog.add(wallet);
                }
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
