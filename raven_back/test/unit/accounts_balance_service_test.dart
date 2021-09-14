// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:raven/raven.dart';
import '../fixtures/fixtures.dart' as fixtures;

var newHistory = History(
    hash: '100',
    scripthash: 'abc100',
    height: 0,
    security: RVN,
    position: 5,
    value: 25);

void main() async {
  group('BalanceService', () {
    setUp(fixtures.useFixtureSources);

    test('make BalanceService', () {
      expect(balanceService is BalanceService, true);
    });

    test('sumBalance (not in mempool)', () {
      expect(
          balanceService
              .sumBalance(fixtures.wallets().map['0']!, RVN)
              .confirmed,
          15);
    });

    test('sumBalance (in mempool)', () {
      expect(
          balanceService
              .sumBalance(fixtures.wallets().map['0']!, RVN)
              .unconfirmed,
          10);
    });

    test('getChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = balanceService.getChangedBalances([change!]);
      expect(changedBalances.toList(), [
        Balance(walletId: '0', security: RVN, confirmed: 40, unconfirmed: 10)
      ]);
      // getChangedBalances doesn't save the result
      expect(balanceService.balances.data, fixtures.balances().map.values);
    });

    test('saveChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = await balanceService.saveChangedBalances([change!]);
      var updatedBalance =
          Balance(walletId: '0', security: RVN, confirmed: 40, unconfirmed: 10);
      expect(changedBalances.toList(), [updatedBalance]);
      // saveChangedBalances saves the result
      expect(balanceService.balances.primaryIndex.getOne('0', RVN),
          updatedBalance);
    });

    test('sortedUnspents', () {
      expect(balanceService.sortedUnspents(fixtures.accounts().map['a0']!), [
        fixtures.histories().map['3'], // 10 RVN
        fixtures.histories().map['0'], // 5 RVN
      ]);
    });

    test('collectUTXOs', () {
      var account = fixtures.accounts().map['a0']!;
      expect(() => balanceService.collectUTXOs(account, amount: 16),
          throwsException);
      expect(balanceService.collectUTXOs(account, amount: 15),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
      expect(balanceService.collectUTXOs(account, amount: 14),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
    });
  });
}
