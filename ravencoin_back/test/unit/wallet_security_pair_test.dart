// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:ravencoin_back/services/wallet_security_pair.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

import '../fixtures/fixtures.dart' as fixtures;
import '../fixtures/sets.dart' as sets;

void main() async {
  var wallet;
  setUp(() {
    fixtures.useFixtureSources(1);
    wallet = pros.wallets.records.first as LeaderWallet;
  });

  test('WalletSecurityPair is unique in Set', () {
    var s = <WalletSecurityPair>{};
    var pair = WalletSecurityPair(
        wallet: wallet,
        security:
            Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test));
    s.add(pair);
    s.add(pair);
    expect(s.length, 1);
  });

  test('securityPairsFromVoutChanges', () {
    var changes = [
      Added(0, sets.FixtureSet1().vouts['0']),
      Added(1, sets.FixtureSet1().vouts['1']),
      Updated(0, sets.FixtureSet1().vouts['0'])
    ];
    var pairs = securityPairsFromVoutChanges(changes);
    expect(pairs, {
      WalletSecurityPair(wallet: wallet, security: pros.securities.RVN),
      WalletSecurityPair(
          wallet: wallet,
          security: Security(
              symbol: 'MOONTREE', chain: Chain.ravencoin, net: Net.test)),
    });
  });
}
