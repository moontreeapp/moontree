/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'package:raven_back/streams/wallet.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  Set<Change<Wallet>> backlog = {};
  final _backlogLock = ReaderWriterLock();

  void init() {
    /*
    listen(
      'wallets/cipher',
      CombineLatestStream.combine2(
        streams.wallet.replay,
        streams.cipher.latest,
        (Wallet wallet, Cipher cipher) => Tuple2(wallet, cipher),
      ),
      (Tuple2<Wallet, Cipher> tuple) {
        print('WALLETS/CIPHER ${tuple.item1} ${tuple.item2}');
        if (tuple.item1 is LeaderWallet) {
          dispatch(tuple.item1 as LeaderWallet);
        }
      },
    );
    */

    listen(
      'connected/cipher',
      CombineLatestStream.combine2(
        streams.client.connected,
        streams.cipher.latest,
        (ConnectionStatus connectionStatus, Cipher cipher) =>
            Tuple2(connectionStatus, cipher),
      ),
      (Tuple2<ConnectionStatus, Cipher> tuple) {
        print('connected/CIPHER ${tuple.item1} ${tuple.item2}');
        if (tuple.item1 is LeaderWallet) {
          dispatch(tuple.item1 as LeaderWallet);
        }
      },
    );

    // automatically make first leader wallet if there isn't one already
    //listen(
    //  'cipher.latest,',
    //  streams.cipher.latest,
    //  (Cipher cipher) => services.wallet.leader.makeFirstWallet(cipher),
    //);

    /// necessary?
    //listen(
    //  'ciphers.changes',
    //  res.ciphers.changes,
    //  (Change<Cipher> change) {
    //    change.when(
    //      loaded: (loaded) async =>
    //          await attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
    //      added: (added) async =>
    //          await attemptLeaderWalletAddressDerive(change.data.cipherUpdate),
    //      updated: (updated) {},
    //      removed: (removed) {},
    //    );
    //  },
    //);
    /* no cipher...
    listen('streams.client.connected', streams.client.connected,
        (ConnectionStatus connected) {
      res.wallets.leaders.forEach((wallet) =>
              //wallet.addresses.isEmpty ?
              dispatch(wallet)
          //:
          /// perhaps here we should run a process that only updates at the end
          /// like newLeaderProcess, and we should subscribe at the end of it
          /// instead of automatically subscribing to all addresses on
          /// connection?
          //(){}
          );
    });
    */
    listen(
      'streams.wallet.leaderChanges',
      CombineLatestStream.combine2(
          streams.wallet.leaderChanges,
          streams.client.connected,
          (Change<Wallet> change, ConnectionStatus connection) =>
              Tuple2(change, connection)),
      (Tuple2<Change<Wallet>, ConnectionStatus> tuple) async {
        final change = tuple.item1;
        final status = tuple.item2;
        print('status, change $status, $change');
        await _backlogLock.write(() => backlog.add(change));
        if (status == ConnectionStatus.connected) {
          await _backlogLock.read(() {
            for (var walletChange in backlog) {
              handleLeaderChange(walletChange);
            }
          });
          await _backlogLock.write(() => backlog.clear());
        } else {}
      },
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

  Future<void> dispatch(LeaderWallet leader) async {
    if (leader.addresses.isEmpty) {
      await services.wallet.leader.newLeaderProcess(leader);
    } else {
      await handleDeriveAddress(leader: leader);
    }
  }

  void handleLeaderChange(Change<Wallet> change) {
    change.when(loaded: (loaded) async {
      // never gets called because we load before this waiter is listening...
      if (loaded.data is LeaderWallet) {
        var leader = loaded.data as LeaderWallet;
        if (leader.addresses.isEmpty) {
          await services.wallet.leader.newLeaderProcess(leader);
        } else {
          await handleDeriveAddress(leader: leader);
        }
      }
    }, added: (added) async {
      if (added.data is LeaderWallet) {
        await dispatch(added.data as LeaderWallet);
      }
    }, updated: (updated) async {
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
    }, removed: (removed) {
      /// should only happen when replacing the initial blank wallet
      var wallet = removed.data;
      res.addresses.removeAll(wallet.addresses.toList());
    });
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
