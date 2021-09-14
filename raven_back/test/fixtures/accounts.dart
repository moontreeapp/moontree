import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Account> accounts() {
  return MapSource({
    'a0': Account(
      name: 'Account a0',
      accountId: 'a0',
    ),
    'a1': Account(
      name: 'Account a1',
      accountId: 'a1',
    ),
  });
}
