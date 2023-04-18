// dart test test/unit/process_test.dart
import 'package:test/test.dart';

import 'package:client_back/client_back.dart';

import '../fixtures/fixtures.dart' as fixtures;
import '../helper/proclaim_changes.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;

void main() {
  group('addresses', () {
    //late LeaderWallet wallet;
    setUp(() async {
      fixtures.useEmptyFixtures();
      dotenv.load();
      await pros.wallets.save(LeaderWallet(
          id: '0',
          encryptedEntropy:
              bip39.mnemonicToEntropy(dotenv.env['TEST_WALLET_01']!)));
      //wallet = pros.wallets.data.first as LeaderWallet;
    });
    test('2 addresses get created', () async {
      expect(pros.addresses.length, 0);
      await proclaimChanges(pros.addresses, () {}, 2);
      expect(pros.addresses.length, 2);
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
