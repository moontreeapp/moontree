// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:raven_back/raven_back.dart';
import '../../fixtures/fixtures.dart' as fixtures;

void main() async {
  //late LeaderWallet wallet;

  setUp(() {
    fixtures.useFixtureSources(1);
    //wallet = res.wallets.data.first as LeaderWallet;
  });
  group('BalanceService', () {
    setUp(fixtures.useFixtureSources1);

    test('saveChangedBalances', () async {
      var updatedBalance = Balance(
          walletId: '0',
          security: res.securities.RVN,
          confirmed: 15000000,
          unconfirmed: 10000000);
      expect(res.balances.primaryIndex.getOne('0', res.securities.RVN),
          updatedBalance);
    });

    test('collectUTXOs', () {
      expect(() => services.balance.collectUTXOs(amount: 16), throwsException);
    });
  });
}
