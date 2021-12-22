// dart test .\test\integration\transaction_test.dart
import 'package:raven_back/raven_back.dart';
import 'package:test/test.dart';

import 'package:raven_back/globals.dart';
import '../fixtures/fixtures.dart' as fixtures;

void main() async {
  setUp(fixtures.useFixtureSources);
  tearDown(fixtures.deleteDatabase);

  group('create TransactionRecords list', () {
    test('', () {
      // for testing
      print('accounts: ${accounts.data}');
      print('accounts: ${transactions.data}');
      print('accounts: ${vins.data}');
      print('accounts: ${vouts.data}');
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
