/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:raven_back/raven_back.dart';
//import 'package:raven_back/utils/transform.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  //Set<LeaderWallet> backlog = {};

  void init() {
    listen(
      'ciphers.changes',
      ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          // if this cipher update is in the list of wallets missing ciphers...
          // initialize the wallet and remove it from the list of wallets missing ciphers
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

    // this is getting triggered before we have a client on occasion
    // https://github.com/moontreeapp/moontree/issues/43
    // .toExistingAddresses()

    //listen(
    //  'streams.wallet.leaderChanges',
    //  streams.wallet.leaderChanges,
    //  (Change<Wallet> change) {

    listen(
      'streams.client.connected||streams.wallet.leaderChanges',
      CombineLatestStream.combine2(
        streams.client.connected,
        streams.wallet.leaderChanges,
        (bool connected, Change<Wallet> change) => Tuple2(connected, change),
      ),
      (Tuple2 tuple) {
        bool connected = tuple.item1;
        Change<Wallet> change = tuple.item2;
        if (connected) {
          change.when(
              loaded: (loaded) {},
              added: (added) {
                var leader = added.data;
                if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
                  services.wallet.leader
                      .deriveMoreAddresses(leader as LeaderWallet);
                  services.client.subscribe.toExistingAddresses();
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
                await balances
                    .removeAll(balances.byWallet.getAll(leader.walletId));

                // remove the index from the registry
                for (var exposure in [
                  NodeExposure.External,
                  NodeExposure.Internal
                ]) {
                  services.wallet.leader.addressRegistry.remove(
                    services.wallet.leader
                        .addressRegistryKey(leader as LeaderWallet, exposure),
                  );
                }
                // recreate the addresses of that wallet
                if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
                  services.wallet.leader
                      .deriveMoreAddresses(leader as LeaderWallet);
                  services.client.subscribe.toExistingAddresses();
                } else {
                  services.wallet.leader.backlog.add(leader as LeaderWallet);
                }
              },
              removed: (removed) {});
        }
      },
      autoDeinit: true,
    );
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
