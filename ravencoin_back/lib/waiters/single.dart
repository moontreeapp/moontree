import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';

import 'package:ravencoin_back/waiters/waiter.dart';

class SingleWaiter extends Waiter {
  void init() {
    listen(
      'ciphers.changes',
      pros.ciphers.changes,
      (Change<Cipher> change) {
        change.when(
          // if this cipher update is in the list of wallets missing ciphers...
          // initialize the wallet and remove it from the list of wallets missing ciphers
          loaded: (Loaded<Cipher> loaded) {
            attemptSingleWalletAddressDerive(change.record.cipherUpdate);
          },
          added: (Added<Cipher> added) {
            attemptSingleWalletAddressDerive(change.record.cipherUpdate);
          },
          updated: (Updated<Cipher> updated) {},
          removed: (Removed<Cipher> removed) {},
        );
      },
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (ConnectionStatus status) {
        if (status == ConnectionStatus.connected) {
          pros.wallets.singles.forEach(checkGap);
        }
      },
    );

    listen(
      'streams.wallet.singleChanges',
      streams.wallet.singleChanges,
      (Change<Wallet> change) {
        change.when(
            loaded: (Loaded<Wallet> loaded) {},
            added: (Added<Wallet> added) async {
              checkGap(added.record as SingleWallet);
            },
            updated: (Updated<Wallet> updated) {
              /* never happens */
            },
            removed: (Removed<Wallet> removed) {
              /* handled by LeadersWaiter*/
            });
      },
    );
  }

  Future<void> attemptSingleWalletAddressDerive(
      CipherUpdate cipherUpdate) async {
    for (final SingleWallet wallet in pros.wallets.singles) {
      if (wallet.cipherUpdate == cipherUpdate) {
        checkGap(wallet);
      }
    }
  }

  Future<void> checkGap(SingleWallet wallet) async {
    if (!services.wallet.single.gapSatisfied(wallet)) {
      if (wallet.cipher != null) {
        print('SAVING ADDRESS FOR SINGLE WALLET IN BACKLOG');
        await pros.addresses
            .save(await services.wallet.single.toAddress(wallet));
      }
    }
  }
}
