/// this waiter is entirely concerned with derviving addresses:
/// each time a new wallet is saved, and
/// each time a new vout is saved that can be tied to a wallet we own.

import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/client.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class LeaderWaiter extends Trigger {
  Set<Change<Wallet>> backlog = <Change<Wallet>>{};
  final ReaderWriterLock _backlogLock = ReaderWriterLock();

  void init() {
    /*
    when(
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
    when(
        thereIsA: CombineLatestStream.combine2(
            streams.client.connected,
            pros.ciphers.changes,
            (ConnectionStatus connectionStatus, Change<Cipher> change) =>
                Tuple2<ConnectionStatus, Change<Cipher>>(
                    connectionStatus, change)).where(
            (Tuple2<ConnectionStatus, Change<Cipher>> t) =>
                t.item2.record.cipherType !=
                    CipherType.none && // only on startup
                t.item1 == ConnectionStatus.connected),
        doThis: (Tuple2<ConnectionStatus, Change<Cipher>> tuple) async =>
            pros.wallets.leaders.forEach(checkGap));

    when(
      thereIsA: streams.wallet.leaderChanges,
      doThis: (Change<Wallet> change) async {
        await _backlogLock.write(() => backlog.add(change));
        if (streams.client.connected.value == ConnectionStatus.connected) {
          await _backlogLock.read(() => backlog.forEach(handleLeaderChange));
          await _backlogLock.write(() => backlog.clear());
        }
      },
    );

    /// not triggered except by it's own instantiation
    //when(
    //  'streams.wallet.deriveAddress',
    //  streams.wallet.deriveAddress,
    //  (DeriveLeaderAddress? deriveDetails) async => deriveDetails == null
    //      ? () {/* do nothing */}
    //      : await services.wallet.leader.handleDeriveAddress(
    //          leader: deriveDetails.leader,
    //          exposure: deriveDetails.exposure,
    //        ),
    //);
  }

  void handleLeaderChange(Change<Wallet> change) {
    change.when(
        // never gets called because we load before this waiter is listening...
        loaded: (Loaded<Wallet> loaded) async {},
        added: (Added<Wallet> added) async {
          if (added.record is LeaderWallet) {
            await services.wallet.leader
                .handleDeriveAddress(leader: added.record as LeaderWallet);
          }
        },
        updated: (Updated<Wallet> updated) async {
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
        },
        removed: (Removed<Wallet> removed) {
          /// should only happen when replacing the initial blank wallet
          pros.addresses.removeAll(removed.record.addresses.toList());
        });
  }

  Future<void> checkGap(LeaderWallet wallet) async {
    if (!services.wallet.leader.gapSatisfied(wallet)) {
      await services.wallet.leader.handleDeriveAddress(leader: wallet);
    }
  }
}
