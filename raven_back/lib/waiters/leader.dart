/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/wallet.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  void init() {
    listen(
      'ciphers.changes',
      res.ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          loaded: (loaded) =>
              attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
          added: (added) =>
              attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
          updated: (updated) {},
          removed: (removed) {},
        );
      },
      autoDeinit: true,
    );

    listen(
      'streams.wallet.leaderChanges',
      streams.wallet.leaderChanges,
      (Change<Wallet> change) => handleLeaderChange(change),
      autoDeinit: true,
    );

    listen(
      'streams.wallet.deriveAddress',
      streams.wallet.deriveAddress,
      (DeriveLeaderAddress? deriveDetails) => deriveDetails == null
          ? () {/* do nothing */}
          : handleDeriveAddress(
              leader: deriveDetails.leader, exposure: deriveDetails.exposure),
      autoDeinit: true,
    );
  }

  void handleLeaderChange(Change<Wallet> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) =>
            handleDeriveAddress(leader: added.data as LeaderWallet),
        updated: (updated) async {
          /// when wallet is moved from one account to another...
          /// we need to derive all the addresses again because it might
          /// have moved from a testnet account to a mainnet account.
          // remove addresses of the wallet
          var leader = updated.data;
          await res.addresses.removeAll(leader.addresses);
          await res.balances
              .removeAll(res.balances.byWallet.getAll(leader.walletId));

          // remove the index from the registry
          for (var exposure in [NodeExposure.External, NodeExposure.Internal]) {
            services.wallet.leader.addressRegistry.remove(
              services.wallet.leader
                  .addressRegistryKey(leader as LeaderWallet, exposure),
            );
          }
          // recreate the addresses of that wallet
          handleDeriveAddress(leader: leader as LeaderWallet);
        },
        removed: (removed) {});
  }

  void attemptLeaderWalletAddressDerive(CipherUpdate cipherUpdate) {
    var remove = <LeaderWallet>{};
    for (var wallet in services.wallet.leader.backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        handleDeriveAddress(leader: wallet, bypassCipher: true);
        remove.add(wallet);
      }
    }
    for (var wallet in remove) {
      services.wallet.leader.backlog.remove(wallet);
    }
  }

  void handleDeriveAddress({
    required LeaderWallet leader,
    NodeExposure? exposure,
    bool bypassCipher = false,
  }) {
    // needs improvement
    //var msg = 'Downloading transactions...';
    //services.busy.clientOn(msg);

    if (bypassCipher ||
        res.ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
      services.wallet.leader.deriveMoreAddresses(
        leader,
        exposures: exposure == null ? null : [exposure],
      );
    } else {
      services.wallet.leader.backlog.add(leader);
    }

    // move to build balances, and clear all messages, not just one.
    //services.busy.clientOff(msg);
  }
}
