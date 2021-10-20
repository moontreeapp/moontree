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
            //if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
            if (cipherRegistry.ciphers.keys.contains(wallet.cipherUpdate)) {
              // if cipher is available for wallet, use it
              //services.wallet.leader.deriveFirstAddressAndSave(wallet);
              services.wallet.leader.maybeSaveNewAddresses(
                  wallet,
                  //ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
                  cipherRegistry.ciphers[wallet.cipherUpdate]!,
                  NodeExposure.External);
              services.wallet.leader.maybeSaveNewAddresses(
                  wallet,
                  //ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
                  cipherRegistry.ciphers[wallet.cipherUpdate]!,
                  NodeExposure.Internal);
            } else {
              // else add it to backlog
              backlogLeaderWallets.add(wallet);
            }
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          // Unhandled Exception: type 'LeaderWallet' is not a subtype of type 'Account'
          // first of all, when are we removing addresses!?
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
        //services.wallet.leader.deriveFirstAddressAndSave(wallet);
        services.wallet.leader.maybeSaveNewAddresses(
            wallet,
            cipherRegistry.ciphers[wallet.cipherUpdate]!,
            NodeExposure.External);
        services.wallet.leader.maybeSaveNewAddresses(
            wallet,
            cipherRegistry.ciphers[wallet.cipherUpdate]!,
            NodeExposure.Internal);
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }
}
