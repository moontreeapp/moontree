import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'package:raven/waiters/waiter.dart';
import 'package:raven/raven.dart';

class AccountWaiter extends Waiter {
  void init() {
    listen(
      'accounts/cipher',
      CombineLatestStream.combine2(
          streams.account.replay,
          streams.cipher.latest,
          (Account account, Cipher cipher) => Tuple2(account, cipher)),
      (Tuple2<Account, Cipher> tuple) {
        services.account.makeFirstWallet(tuple.item1, tuple.item2);
      },
    );
  }
}
