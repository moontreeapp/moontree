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

    listen('wallets.batchedChanges', wallets.batchedChanges,
        (List<Change<Wallet>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var wallet = added.data;
              if (wallet is LeaderWallet) {
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  // if cipher is available for wallet, use it
                  //services.wallet.leader.deriveFirstAddressAndSave(wallet);
                  services.wallet.leader.maybeSaveNewAddresses(
                      wallet,
                      ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
                      NodeExposure.External);
                  services.wallet.leader.maybeSaveNewAddresses(
                      wallet,
                      ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
                      NodeExposure.Internal);
                } else {
                  // else add it to backlog
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
  }

  Set<LeaderWallet> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <LeaderWallet>{};
    for (var wallet in backlogLeaderWallets) {
      if (wallet.cipherUpdate == cipherUpdate) {
        //services.wallet.leader.deriveFirstAddressAndSave(wallet);
        services.wallet.leader.maybeSaveNewAddresses(
            wallet,
            ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
            NodeExposure.External);
        services.wallet.leader.maybeSaveNewAddresses(
            wallet,
            ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
            NodeExposure.Internal);
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }
}
