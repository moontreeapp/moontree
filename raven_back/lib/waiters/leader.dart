/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:raven/raven.dart';
import 'package:raven/utils/transform.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  Set<LeaderWallet> backlog = {};

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

    listen(
      'streams.wallet.leaderChanges',
      streams.wallet.leaderChanges,
      (Change<Wallet> change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var leader = added.data;
              if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
                services.wallet.leader
                    .deriveMoreAddresses(leader as LeaderWallet);
                services.client.subscribe.toExistingAddresses();
              } else {
                backlog.add(leader as LeaderWallet);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      },
      autoDeinit: true,
    );

    listen(
      'vouts/addresses',
      CombineLatestStream.combine2(
          vouts.changes
              .where((change) => change is Added)
              .map((change) => change.data),
          addresses.changes
              .where((change) => change is Added)
              .map((change) => change.data),
          (Vout vout, Address address) => Tuple2(vout, address)),
      (Tuple2<Vout, Address> tuple) {
        // if vout has wallet, derive,
        //  (this means the address exists already so when the address was made
        //  the vouts did not exist, and did not trigger an address derivation.)
        // else if address has vout derive.
        //  (this means it's vouts have been pull before the address was
        //  created, which means when the vouts were created they had no
        //  matching address, and didn't trigger an address derivation)
        // if vout has no wallet and address has no vout don't derive.
        var vout = tuple.item1;
        var address = tuple.item2;
        var wallet;
        if (vout.wallet is LeaderWallet) {
          wallet = vout.wallet as LeaderWallet;
        } else if (address.wallet is LeaderWallet) {
          wallet = address.wallet as LeaderWallet;
        }
        if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
          var derived = services.wallet.leader.deriveMoreAddresses(
            wallet,
            exposures: [vout.address!.exposure],
          );
          services.client.subscribe.toExistingAddresses();
          for (var addressId in derived.map((address) => address.addressId)) {
            if (!services.address.retrieved.contains(addressId)) {
              services.address.unretrieved.add(addressId);
            }
          }
        } else {
          backlog.add(wallet);
        }
      },
    );
  }

  void attemptLeaderWalletAddressDerive(
    CipherUpdate cipherUpdate,
  ) {
    var remove = <LeaderWallet>{};
    for (var wallet in backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        services.wallet.leader.deriveMoreAddresses(wallet);
        remove.add(wallet);
      }
    }
    services.client.subscribe.toExistingAddresses();
    for (var wallet in remove) {
      backlog.remove(wallet);
    }
  }
}
