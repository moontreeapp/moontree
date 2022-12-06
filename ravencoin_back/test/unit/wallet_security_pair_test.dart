// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:ravencoin_back/services/wallet_security_pair.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

import '../fixtures/fixtures.dart' as fixtures;
import '../fixtures/sets.dart' as sets;

void main() async {
  setUp(() {
    fixtures.useFixtureSources(1);
  });

  test('WalletSecurityPair is unique in Set', () {
    final LeaderWallet wallet = pros.wallets.records.first as LeaderWallet;
    final Set<WalletSecurityPair> s = <WalletSecurityPair>{};
    final WalletSecurityPair pair = WalletSecurityPair(
        wallet: wallet,
        security: const Security(
            symbol: 'RVN', chain: Chain.ravencoin, net: Net.test));
    s.add(pair);
    s.add(pair);
    expect(s.length, 1);
  });

  test('securityPairsFromVoutChanges', () {
    final LeaderWallet wallet = pros.wallets.records.first as LeaderWallet;
    final List<Change<Vout>> changes = <Change<Vout>>[
      Added<Vout>(0, sets.FixtureSet1().vouts['0']!),
      Added<Vout>(1, sets.FixtureSet1().vouts['1']!),
      Updated<Vout>(0, sets.FixtureSet1().vouts['0']!)
    ];
    final Set<WalletSecurityPair> pairs = securityPairsFromVoutChanges(changes);
    expect(pairs, {
      WalletSecurityPair(wallet: wallet, security: pros.securities.RVN),
      WalletSecurityPair(
          wallet: wallet,
          security: const Security(
              symbol: 'MOONTREE', chain: Chain.ravencoin, net: Net.test)),
    });
  });
}
