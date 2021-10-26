import 'package:raven/records/cipher.dart';
import 'package:raven/utils/streaming_joins.dart';
import 'package:rxdart/rxdart.dart';
import 'package:reservoir/reservoir.dart' show Change;

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  void init() {
    // var addCipherStream = ciphers.changes.whereType<Added<Cipher>>();
    //
    // var stream = streamingLeftJoin(
    //   ciphers.batchedChanges.flatMap<Cipher>((value) => null),
    //   accounts.batchedChanges,
    //   (List<Change<Cipher>> batchedChanges) {
    //     return services.cipher.currentCipher == null ? 'null' : 'not-null';
    //   },
    //   (List<Change<Account>> batchedChanges) {
    //     return 'not-null';
    //   },
    // );

    // listen('ciphers/accounts', stream,
    //     (Join<List<Change<Cipher>>, List<Change<Account>>> row) {});

    listen('ciphers.batchedChanges', ciphers.batchedChanges,
        (List<Change<Cipher>> batchedChanges) async {
      batchedChanges.forEach((change) => change.when(
          loaded: (loaded) {},
          added: (added) {
            if (added.data.cipher == services.cipher.currentCipher) {
              backlog.forEach((account) {
                makeFirstWallet(account);
              });
            }
          },
          updated: (updated) {},
          removed: (removed) {}));
    });

    /// this listener implies we have to load everthing backwards if importing:
    /// first balances, histories, addresses, wallets and then accounts
    listen<List<Change<Account>>>(
        'accounts.batchedChanges', accounts.batchedChanges, (batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var account = added.data;
              if (services.cipher.currentCipher == null) {
                backlog.add(account);
              } else {
                makeFirstWallet(account);
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    });
  }

  void makeFirstWallet(Account account) {
    if (wallets.byAccount.getAll(account.accountId).isEmpty) {
      services.wallet.leader.makeSaveLeaderWallet(
          account.accountId, services.cipher.currentCipher!,
          cipherUpdate: services.cipher.currentCipherUpdate);
    }
  }
}
