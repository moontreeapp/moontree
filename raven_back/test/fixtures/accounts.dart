import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:reservoir/map_source.dart';

import 'package:raven_back/records/records.dart';

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


/*
todo:
0. write a test that builds transacions (with fees) correctly (with mock data)
1. write a test to which makes an account and a wallet using the .env, and an address for it.
2. get some test $$ into that address 
3. make a transaction with transaction builder and test with dust (integration)
4. make a transaction with transaction builder and test various fees (manual)
*/