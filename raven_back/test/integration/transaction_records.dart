// dart test .\test\integration\transaction_test.dart
import 'package:raven_back/raven_back.dart';
import 'package:test/test.dart';

import 'package:raven_back/globals.dart';
import '../fixtures/fixtures.dart' as fixtures;

void main() async {
  setUp(fixtures.useFixtureSources1);
  tearDown(fixtures.deleteDatabase);

  group('create TransactionRecords list', () {
    test('', () {
      // for testing
      print('accounts: ${res.accounts.data}');
      print('accounts: ${res.transactions.data}');
      print('accounts: ${res.vins.data}');
      print('accounts: ${res.vouts.data}');
      //print('wallets: ${wallets.data}');
      //print('passwords: ${passwords.data}');
      //print('addresses: ${addresses.data}');
      //print('balances: ${balances.data}');
      //print('rates: ${rates.data}');
      //print('settings: ${settings.data}');
      /* test */
      services.transaction.getTransactionRecords();
    });
  });
}
