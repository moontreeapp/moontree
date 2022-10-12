// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import '../../fixtures/fixtures.dart' as fixtures;

void main() async {
  //late LeaderWallet wallet;

  setUp(() {
    fixtures.useFixtureSources(1);
    //wallet = pros.wallets.data.first as LeaderWallet;
  });
  group('BalanceService', () {
    setUp(fixtures.useFixtureSources1);

    test('saveChangedBalances', () async {
      var updatedBalance = Balance(
          chain: Chain.ravencoin,
          net: Net.Main,
          walletId: '0',
          security: pros.securities.RVN,
          confirmed: 15000000,
          unconfirmed: 10000000);
      expect(pros.balances.primaryIndex.getOne('0', pros.securities.RVN),
          updatedBalance);
    });

    test('collectUTXOs', () {
      expect(() => services.balance.collectUTXOs(walletId: '0', amount: 16),
          throwsException);
    });
  });
}
