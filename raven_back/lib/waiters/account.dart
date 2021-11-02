import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';
import 'package:raven/records/cipher.dart';
import 'package:raven/utils/maximum_ext.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  static final Stream<Password?> latestPassword$ = BehaviorSubject.seeded(null)
    ..addStream(passwords.changes
        .where((change) => change is Loaded || change is Added)
        .map((change) => change.data)
        .maximum((p1, p2) => p1.passwordId - p2.passwordId));

  static final Stream<bool> passwordExists$ =
      latestPassword$.map((password) => password == null ? false : true);

  static final Stream<Account> replayAccount$ = ReplaySubject<Account>()
    ..addStream(accounts.changes
        .where((change) => change is Loaded || change is Added)
        .map((added) => added.data));

  static final Stream<CipherType> latestCipherType$ = passwordExists$
      .map((bool exists) => exists ? CipherType.AES : CipherType.None);

  static final latestCipherUpdate$ = CombineLatestStream.combine2(
      latestCipherType$,
      latestPassword$,
      (CipherType cipherType, Password? password) =>
          CipherUpdate(cipherType, passwordId: password?.passwordId));

  static final Stream<Cipher> latestCipher$ = CombineLatestStream.combine2(
          ciphers.changes,
          latestCipherUpdate$,
          (Change<Cipher> change, CipherUpdate cipherUpdate) =>
              ciphers.primaryIndex.getOne(cipherUpdate))
      .whereType<Cipher>()
      .distinctUnique();

  void init() {
    var combined = CombineLatestStream.combine2(replayAccount$, latestCipher$,
        (Account account, Cipher cipher) => Tuple2(account, cipher));

    listen('accounts/cipher', combined, (Tuple2<Account, Cipher> tuple) {
      services.account.makeFirstWallet(tuple.item1, tuple.item2);
    });
  }
}
