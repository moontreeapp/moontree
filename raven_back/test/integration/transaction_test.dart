// dart test .\test\integration\transaction_test.dart
import 'package:raven/raven.dart';
import 'package:test/test.dart';

import 'package:raven/services/client.dart';
import 'package:raven/services/transaction_maker.dart';
import 'package:raven/globals.dart';
import '../fixtures/fixtures_live.dart' as fixtures;

void main() async {
  setUp(fixtures.useLiveSources);
  tearDown(fixtures.deleteDatabase);

  group('SendTransaction', () {
    test('', () {
      // for testing
      print('accounts: ${accounts.data}');
      print('wallets: ${wallets.data}');
      print('passwords: ${passwords.data}');
      print('addresses: ${addresses.data}');
      print('balances: ${balances.data}');
      print('rates: ${rates.data}');
      print('settings: ${settings.data}');
      /* errors */
      var tuple = services.transact.buildTransaction(
        accounts.primaryIndex.getByKeyStr('Primary').first,
        addresses.byWallet
            .getAll(wallets.byAccount
                .getOne(accounts.primaryIndex
                    .getByKeyStr('Secondary')[0]
                    .accountId)!
                .walletId)[0]
            .address,
        SendEstimate(1),
      );
      var txb = tuple.item1;
      var estimate = tuple.item2;
      print(estimate);
      //var txid = services.client.sendTransaction(txb.tx!.toHex());
      //print(txid);
      //print('https://rvnt.cryptoscope.io/tx/?txid=$txid');
      //expect(txb.tx!.version, 1);
    });
  });
}
