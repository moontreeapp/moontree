// dart test test/unit/process_test.dart
import 'dart:typed_data';

import 'package:raven/records.dart';
import 'package:raven/services.dart';
import 'package:raven/reservoirs.dart';
import 'package:test/test.dart';

import 'package:reservoir/reservoir.dart';

import '../helper/reservoir_changes.dart';

void main() {
  group('addresses', () {
    late AccountReservoir accounts;
    late WalletReservoir wallets;
    late AddressReservoir addresses;
    late HistoryReservoir histories;
    late LeaderWalletDerivationService leaderWalletDerivationService;
    late Account account;
    late LeaderWallet wallet;
    setUp(() async {
      accounts = AccountReservoir(MapSource<String, Account>());
      wallets = WalletReservoir(MapSource<String, Wallet>());
      addresses = AddressReservoir(MapSource<String, Address>());
      histories = HistoryReservoir(MapSource<String, History>());
      leaderWalletDerivationService = LeaderWalletDerivationService(
        accounts,
        wallets,
        addresses,
        histories,
      );
      // make account
      account = Account(
        id: 'a-0',
        name: 'primary',
      );
      // make wallet
      wallet = LeaderWallet(
        id: 'w-0',
        accountId: 'a-0',
        encryptedSeed: Uint8List.fromList(
            [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]),
      );

      // put wallet and account in reservoirs
      await accounts.save(account);
      await wallets.save(wallet);

      expect(accounts.length, 1);
      expect(wallets.length, 1);
    });

    test('2 addresses get created', () async {
      // make addresses
      await reservoirChanges(
          addresses,
          () => leaderWalletDerivationService.deriveFirstAddressAndSave(wallet),
          2);
      expect(addresses.length, 2);
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
