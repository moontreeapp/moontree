// dart test .\test\integration\transaction_test.dart
import 'package:raven_back/raven_back.dart';
import 'package:test/test.dart';

import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/globals.dart';
import '../fixtures/fixtures_live.dart' as fixtures;

void main() async {
  setUp(fixtures.useLiveSources);
  tearDown(fixtures.deleteDatabase);

  group('SendTransaction', () {
    test('', () {
      // for testing
      print('accounts: ${res.accounts.data}');
      print('wallets: ${res.wallets.data}');
      print('passwords: ${res.passwords.data}');
      print('addresses: ${res.addresses.data}');
      print('balances: ${res.balances.data}');
      print('rates: ${res.rates.data}');
      print('settings: ${res.settings.data}');
      /* errors */
      var tuple = services.transaction.make.transaction(
        res.addresses.byWallet
            .getAll(res.wallets.byAccount
                .getOne(res.accounts.primaryIndex
                    .getByKeyStr('Secondary')[0]
                    .accountId)!
                .walletId)[0]
            .address,
        SendEstimate(1),
        account: res.accounts.primaryIndex.getByKeyStr('Primary').first,
      );
      //var txb = tuple.item1;
      var estimate = tuple.item2;
      print(estimate);
      //var txid = services.client.sendTransaction(txb.tx!.toHex());
      //print(txid);
      //print('https://rvnt.cryptoscope.io/tx/?txid=$txid');
      //expect(txb.tx!.version, 1);
    });
  });
}
