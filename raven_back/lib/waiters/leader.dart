/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/wallet.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  void init() {
    /*
    listen(
      'wallets/cipher',
      CombineLatestStream.combine2(
          streams.wallet.replay,
          streams.cipher.latest,
          (Wallet wallet, Cipher cipher) => Tuple2(wallet, cipher)),
      (Tuple2<Wallet, Cipher> tuple) {
        services.wallet.leader.makeFirstWallet(tuple.item2);
      },
    );
    */

    // automatically make first leader wallet if there isn't one already
    listen(
      'cipher.latest,',
      streams.cipher.latest,
      (Cipher cipher) => services.wallet.leader.makeFirstWallet(cipher),
    );

    listen(
      'ciphers.changes',
      res.ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          loaded: (loaded) async =>
              await attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
          added: (added) async =>
              await attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
          updated: (updated) {},
          removed: (removed) {},
        );
      },
    );

    listen(
      'streams.wallet.leaderChanges',
      streams.wallet.leaderChanges,
      (Change<Wallet> change) => handleLeaderChange(change),
    );

    listen(
      'streams.wallet.deriveAddress',
      streams.wallet.deriveAddress,
      (DeriveLeaderAddress? deriveDetails) async {
        deriveDetails == null
            ? () {/* do nothing */}
            : await handleDeriveAddress(
                leader: deriveDetails.leader, exposure: deriveDetails.exposure);
      },
    );
  }

  void handleLeaderChange(Change<Wallet> change) {
    change.when(
        loaded: (loaded) async {
          await handleDeriveAddress(leader: loaded.data as LeaderWallet);
        },
        added: (added) async {
          await handleDeriveAddress(leader: added.data as LeaderWallet);
        },
        updated: (updated) async {
          /*
          /// app is switched to mainnet to testnet or testnet to mainnet... 
          /// we need to derive all the addresses again.
          /// but this should go on that settings listener,
          /// but we actually don't give the user the ability to do that.
          // remove addresses of the wallet
          var leader = updated.data;
          await res.addresses.removeAll(leader.addresses);
          await res.balances
              .removeAll(res.balances.byWallet.getAll(leader.walletId));
          // recreate the addresses of that wallet
          handleDeriveAddress(leader: leader as LeaderWallet);
          */
        },
        removed: (removed) {});
  }

  Future<void> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) async {
    var remove = <LeaderWallet>{};
    for (var wallet in services.wallet.leader.backlog) {
      if (wallet.cipherUpdate == cipherUpdate) {
        await handleDeriveAddress(leader: wallet, bypassCipher: true);
        remove.add(wallet);
      }
    }
    for (var wallet in remove) {
      services.wallet.leader.backlog.remove(wallet);
    }
  }

  Future<void> handleDeriveAddress({
    required LeaderWallet leader,
    NodeExposure? exposure,
    bool bypassCipher = false,
  }) async {
    //var s = Stopwatch()..start();
    if (bypassCipher ||
        res.ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
      await services.wallet.leader.deriveMoreAddresses(
        leader,
        exposures: exposure == null ? null : [exposure],
      );
    } else {
      services.wallet.leader.backlog.add(leader);
    }
    //print('deriving: ${s.elapsed}');
  }
}
