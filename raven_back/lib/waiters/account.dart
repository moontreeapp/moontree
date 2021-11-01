import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';
import 'package:raven/records/cipher.dart';
import 'package:raven/utils/maximum_ext.dart';

class AccountWaiter extends Waiter {
  Set<Account> backlog = {};

  final Stream<Cipher> latestCipher$ = ciphers.changes
      .where(
          (change) => change is Loaded || change is Added || change is Updated)
      .map((change) => change.data)
      .maximum((p1, p2) => (p1.passwordId ?? -1) - (p2.passwordId ?? -1));

  var replayAccount$ = ReplaySubject<Account>()
    ..addStream(accounts.changes
        .where((change) => change is Loaded || change is Added)
        .map((added) => added.data));

  void init() {
    var combined = CombineLatestStream.combine2(replayAccount$, latestCipher$,
        (Account account, Cipher cipher) => Tuple2(account, cipher));

    listen('accounts/cipher', combined, (Tuple2<Account, Cipher> tuple) {
      services.account.makeFirstWallet(tuple.item1, tuple.item2);
    });
  }
}
