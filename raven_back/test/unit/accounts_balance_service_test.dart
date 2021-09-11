// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:raven/records/records.dart';
import 'package:raven/services/services.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/globals.dart';
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
      expect(balanceService.sumBalance('a0', RVN).confirmed, 15);
    });

    test('sumBalance (in mempool)', () {
      expect(balanceService.sumBalance('a0', RVN).unconfirmed, 10);
    });

    test('getChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = balanceService.getChangedBalances([change!]);
      expect(changedBalances.toList(), [
        Balance(walletId: 'a0', security: RVN, confirmed: 40, unconfirmed: 10)
      ]);
      // getChangedBalances doesn't save the result
      expect(balanceService.balances.data, fixtures.balances().map.values);
    });

    test('saveChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = await balanceService.saveChangedBalances([change!]);
      var updatedBalance = Balance(
          walletId: 'a0', security: RVN, confirmed: 40, unconfirmed: 10);
      expect(changedBalances.toList(), [updatedBalance]);
      // saveChangedBalances saves the result
      expect(balanceService.balances.primaryIndex.getOne('a0', RVN),
          updatedBalance);
    });

    test('sortedUnspents', () {
      expect(balanceService.sortedUnspents('a0'), [
        fixtures.histories().map['3'], // 10 RVN
        fixtures.histories().map['0'], // 5 RVN
      ]);
    });

    test('collectUTXOs', () {
      expect(() => balanceService.collectUTXOs('a0', 16), throwsException);
      expect(balanceService.collectUTXOs('a0', 15),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
      expect(balanceService.collectUTXOs('a0', 14),
          [fixtures.histories().map['3'], fixtures.histories().map['0']]);
    });
  });
}
