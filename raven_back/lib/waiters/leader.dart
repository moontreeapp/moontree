/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  void init() {
    listen(
      'ciphers.changes',
      ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          loaded: (loaded) {
            attemptLeaderWalletAddressDerive(change.data.cipherUpdate);
          },
          added: (added) {
            attemptLeaderWalletAddressDerive(change.data.cipherUpdate);
          },
          updated: (updated) {},
          removed: (removed) {},
        );
      },
      autoDeinit: true,
    );

    listen(
      'streams.wallet.leaderChanges',
      streams.wallet.leaderChanges,
      (Change<Wallet> change) => produceLeader(change),
      autoDeinit: true,
    );
  }

  void produceLeader(Change<Wallet> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) {
          var leader = added.data;
          if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
            services.wallet.leader.deriveMoreAddresses(leader as LeaderWallet);
          } else {
            services.wallet.leader.backlog.add(leader as LeaderWallet);
          }
        },
        updated: (updated) async {
          /// when wallet is moved from one account to another...
          /// we need to derive all the addresses again because it might
          /// have moved from a testnet account to a mainnet account.
          // remove addresses of the wallet
          var leader = updated.data;
          await addresses.removeAll(leader.addresses);
          await balances.removeAll(balances.byWallet.getAll(leader.walletId));

          // remove the index from the registry
          for (var exposure in [NodeExposure.External, NodeExposure.Internal]) {
            services.wallet.leader.addressRegistry.remove(
              services.wallet.leader
                  .addressRegistryKey(leader as LeaderWallet, exposure),
            );
          }
          // recreate the addresses of that wallet
          if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
            services.wallet.leader.deriveMoreAddresses(leader as LeaderWallet);
          } else {
            services.wallet.leader.backlog.add(leader as LeaderWallet);
          }
        },
        removed: (removed) {});
  }

  void attemptLeaderWalletAddressDerive(
    CipherUpdate cipherUpdate,
  ) {
    var remove = <LeaderWallet>{};
    for (var wallet in services.wallet.leader.backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        services.wallet.leader.deriveMoreAddresses(wallet);
        remove.add(wallet);
      }
    }
    services.client.subscribe.toExistingAddresses();
    for (var wallet in remove) {
      services.wallet.leader.backlog.remove(wallet);
    }
  }
}
