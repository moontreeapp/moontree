// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:raven_back/raven_back.dart';
import '../../fixtures/fixtures.dart' as fixtures;

var newHistory = History(
    txId: '100',
    addressId: 'abc100',
    height: 0,
    security: fixtures.RVN,
    position: 5,
    value: 25);

void main() async {
  group('BalanceService', () {
    setUp(fixtures.useFixtureSources);

    test('sumBalance (not in mempool)', () {
      expect(
          services.balance
              .sumBalance(fixtures.wallets().map['0']!, fixtures.RVN)
              .confirmed,
          15);
    });

    test('sumBalance (in mempool)', () {
      expect(
          services.balance
              .sumBalance(fixtures.wallets().map['0']!, fixtures.RVN)
              .unconfirmed,
          10);
    });

    test('getChangedBalances', () async {
      var change = (await histories.save(newHistory))!;
      var changedBalances = services.balance.getChangedBalances([change]);
      expect(changedBalances.toList(), [
        Balance(
            walletId: '0',
            security: fixtures.RVN,
            confirmed: 40,
            unconfirmed: 10)
      ]);
      // getChangedBalances doesn't save the result
      expect(balances.data, fixtures.balances().map.values);
    });

    test('saveChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances =
          await services.balance.saveChangedBalances([change!]);
      var updatedBalance = Balance(
          walletId: '0',
          security: fixtures.RVN,
          confirmed: 40,
          unconfirmed: 10);
      expect(changedBalances.toList(), [updatedBalance]);
      // saveChangedBalances saves the result
      expect(balances.primaryIndex.getOne('0', fixtures.RVN), updatedBalance);
    });

    test('sortedUnspents', () {
      expect(services.balance.sortedUnspents(fixtures.accounts()['a0']!), [
        fixtures.histories().map['3'], // 1000 RVN
        fixtures.histories().map['0'], // 500 RVN
      ]);
    });

    test('collectUTXOs', () {
      var account = fixtures.accounts()['a0']!;
      expect(() => services.balance.collectUTXOs(account, amount: 16),
          throwsException);
      expect(services.balance.collectUTXOs(account, amount: 15),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
      expect(services.balance.collectUTXOs(account, amount: 14),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
    });
  });
}
