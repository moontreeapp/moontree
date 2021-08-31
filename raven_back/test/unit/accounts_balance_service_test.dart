// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:raven/records/security.dart';
import 'package:test/test.dart';
import 'package:raven/services/services.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import '../fixtures/fixtures.dart' as fixtures;

void main() async {
  group('BalanceService', () {
    late BalanceReservoir balances;
    late HistoryReservoir histories;
    late BalanceService balanceService;
    setUp(() {
      balances = BalanceReservoir(fixtures.balances);
      histories = HistoryReservoir(fixtures.histories);
      balanceService = BalanceService(balances, histories);
    });

    test('make BalanceService', () {
      expect(balanceService is BalanceService, true);
    });

    test('sumBalance (not in mempool)', () {
      expect(balanceService.sumBalance('a0', RVN).confirmed, 15);
    });
  });
}
