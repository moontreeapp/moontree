/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/streams/wallet.dart';
import 'package:ravencoin_back/utilities/lock.dart';
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

    /// this is used for the case of if we closed the app during
    /// import and never saved the addresses, we want to restart
    /// the import process for this wallet to derive addresses
    listen(
      'connected/cipher',
      CombineLatestStream.combine2(
        streams.client.connected,
        pros.ciphers.changes,
        (ConnectionStatus connectionStatus, Change<Cipher> change) =>
            Tuple2(connectionStatus, change),
      ),
      (Tuple2<ConnectionStatus, Change<Cipher>> tuple) {
        print('connected/CIPHER ${tuple.item1} ${tuple.item2}');
        if (tuple.item2.record.cipherType != CipherType.None) {
          pros.wallets.leaders.forEach((wallet) => dispatch(wallet));
        }
      },
    );

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
      if (!services.wallet.leader.newLeaderProcessRunning) {
        await services.wallet.leader.newLeaderProcess(leader);
      }
    } else {
      await handleDeriveAddress(leader: leader);
    }
  }

  void handleLeaderChange(Change<Wallet> change) {
    change.when(
        // never gets called because we load before this waiter is listening...
        loaded: (loaded) async {
      if (loaded.record is LeaderWallet) {
        await dispatch(loaded.record as LeaderWallet);
      }
    }, added: (added) async {
      if (added.record is LeaderWallet) {
        await dispatch(added.record as LeaderWallet);
      }
    }, updated: (updated) async {
      /*
          /// app is switched to mainnet to testnet or testnet to mainnet... 
          /// we need to derive all the addresses again.
          /// but this should go on that settings listener,
          /// but we actually don't give the user the ability to do that.
          // remove addresses of the wallet
          var leader = updated.record;
          await pros.addresses.removeAll(leader.addresses);
          await pros.balances
              .removeAll(pros.balances.byWallet.getAll(leader.walletId));
          // recreate the addresses of that wallet
          handleDeriveAddress(leader: leader as LeaderWallet);
          */
    }, removed: (removed) {
      /// should only happen when replacing the initial blank wallet
      pros.addresses.removeAll(removed.record.addresses.toList());
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
    if (bypassCipher ||
        pros.ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
      await services.wallet.leader.deriveMoreAddresses(
        leader,
        exposures: exposure == null ? null : [exposure],
      );
    } else {
      services.wallet.leader.backlog.add(leader);
    }
  }
}
