import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:rxdart/subjects.dart';

import 'waiter.dart';

class LeaderWalletAndCipher {
  LeaderWallet? wallet;
  CipherUpdate? cipher;

  LeaderWalletAndCipher(this.wallet, this.cipher);
}

Set<LeaderWalletAndCipher> unmatchedLeaderWalletAndCiphers = {};
BehaviorSubject<LeaderWalletAndCipher> leaderWalletAndCipherSubject =
    BehaviorSubject();

class LeaderWaiter extends Waiter {
  void init() {
    cipherStream.listen((CipherUpdate cipher) {
      if (unmatchedLeaderWalletAndCiphers.contains());
      
      unmatchedLeaderWalletAndCiphers.forEach((leaderWalletAndCipher) {
        if (leaderWalletAndCipher.wallet.cipherUpdate.cipherType ==
            cipher.cipherType) {
          leaderWalletAndCipher.cipher = cipher;
          leaderWalletAndCipherSubject.add(leaderWalletAndCipher);
        } else {
          unmatchedLeaderWalletAndCiphers.add(leaderWalletAndCipher);
        }
      });
    });

    if (!listeners.keys.contains('wallets.changes')) {
      listeners['wallets.changes'] =
          wallets.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(added: (added) {
            var wallet = added.data;

            if (leaderWalletAndCipher)
            // if (wallet is LeaderWallet && wallet.cipher != null) {
            //   services.wallets.leaders.deriveFirstAddressAndSave(wallet);
            // }
          }, updated: (updated) {
            /* moved account */
          }, removed: (removed) {
            addresses.removeAddresses(removed.data);
          });
        });
      });
    }
  }
}
