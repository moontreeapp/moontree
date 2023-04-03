import 'package:client_back/client_back.dart';
import 'package:client_back/streams/client.dart';

import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class SingleWaiter extends Trigger {
  void init() {
    when(
      thereIsA: pros.ciphers.changes,
      doThis: (Change<Cipher> change) {
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

    when(
      thereIsA: streams.client.connected.where(
          (ConnectionStatus status) => status == ConnectionStatus.connected),
      doThis: (ConnectionStatus _) async {
        pros.wallets.singles.forEach(checkGap);
      },
    );

    when(
      thereIsA: streams.wallet.singleChanges,
      doThis: (Change<Wallet> change) {
        change.when(
            loaded: (Loaded<Wallet> loaded) {},
            added: (Added<Wallet> added) async {
              await checkGap(added.record as SingleWallet);
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
    CipherUpdate cipherUpdate,
  ) async {
    for (final SingleWallet wallet in pros.wallets.singles) {
      if (wallet.cipherUpdate == cipherUpdate) {
        await checkGap(wallet);
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
