// dart test test/unit/process_test.dart
import 'package:reservoir/map_source.dart';
import 'package:test/test.dart';

import 'package:raven_back/raven_back.dart';

import '../fixtures/fixtures.dart' as fixtures;
import '../helper/reservoir_changes.dart';

void main() {
  group('addresses', () {
    late Account account;
    late LeaderWallet wallet;
    setUp(() async {
      fixtures.useFixtureSources();

      // make account
      account = Account(
        accountId: 'a0',
        name: 'primary',
      );
      accounts.setSource(MapSource({'a0': account}));
      wallet = fixtures.wallets().map['0'] as LeaderWallet;

      // put account in reservoir
      await accounts.save(account);
      expect(accounts.length, 1);
    });

    test('2 addresses get created', () async {
      // make addresses
      expect(addresses.length, 5);
      await reservoirChanges(
          addresses, () => services.wallet.leader.deriveAddress(wallet, 0), 2);
      expect(addresses.length, 7);
    });

    //test('20 addresses get created', () async {
    //  // make addresses
    //  await reservoirChanges(
    //      addresses,
    //      () => leaderWalletDerivationService.deriveFirstAddressAndSave(wallet),
    //      2);
    //  //changedAddresses
    //  await reservoirChanges(
    //      addresses,
    //      () => leaderWalletDerivationService.maybeDeriveNewAddresses(changedAddresses),
    //      2);
    //  expect(addresses.length, 2);
    //  //await asyncChange(
    //  //  addresses,
    //  //  () => leaderWalletDerivationService.deriveFirstAddressAndSave(wallet),
    //  //);
    //  //expect(addresses.length, 20);
    //});
  });
}
