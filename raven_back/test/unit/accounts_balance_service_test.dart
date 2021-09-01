// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';
import 'package:reservoir/change.dart';

import 'package:raven/records/records.dart';
import 'package:raven/services/services.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import '../fixtures/fixtures.dart' as fixtures;

var newHistory = History(
    hash: '0',
    scripthash: 'abc0',
    accountId: 'a0',
    walletId: 'w0',
    height: 0,
    security: RVN,
    position: 5,
    value: 25);

void main() async {
  group('BalanceService', () {
    late BalanceReservoir balances;
    late HistoryReservoir histories;
    late BalanceService balanceService;

    setUp(() {
      balances = BalanceReservoir(fixtures.balances());
      histories = HistoryReservoir(fixtures.histories());
      balanceService = BalanceService(balances, histories);
    });

    test('make BalanceService', () {
      expect(balanceService is BalanceService, true);
    });

    test('sumBalance (not in mempool)', () {
      expect(balanceService.sumBalance('a0', RVN).confirmed, 15);
    });

    test('sumBalance (in mempool)', () {
      expect(balanceService.sumBalance('a1', RVN).unconfirmed, 10);
    });

    test('getChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = balanceService.getChangedBalances([change!]);
      expect(changedBalances.toList(), [
        Balance(accountId: 'a0', security: RVN, confirmed: 40, unconfirmed: 0)
      ]);
      // getChangedBalances doesn't save the result
      expect(balanceService.balances.data, fixtures.balances().map.values);
    });

    test('saveChangedBalances', () async {
      var change = await histories.save(newHistory);
      var changedBalances = await balanceService.saveChangedBalances([change!]);
      var updatedBalance = Balance(
          accountId: 'a0', security: RVN, confirmed: 40, unconfirmed: 0);
      expect(changedBalances.toList(), [updatedBalance]);
      // saveChangedBalances saves the result
      expect(balanceService.balances.primaryIndex.getAll('a0', RVN),
          [updatedBalance]);
    });
  });
}
