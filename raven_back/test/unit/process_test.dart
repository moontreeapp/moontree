// dart test test/unit/process_test.dart
import 'dart:typed_data';

import 'package:raven/records.dart';
import 'package:raven/services.dart';
import 'package:raven/reservoirs.dart';
import 'package:test/test.dart';

import '../reservoir/helper.dart';
import '../reservoir/rx_map_source.dart';

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
      accounts = AccountReservoir(RxMapSource<String, Account>());
      wallets = WalletReservoir(RxMapSource<String, Wallet>());
      addresses = AddressReservoir(RxMapSource<String, Address>());
      histories = HistoryReservoir(RxMapSource<String, History>());
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
      await reservoirChanges(
        accounts,
        () => accounts.save(account),
      );
      await reservoirChanges(
        wallets,
        () => wallets.save(wallet),
      );
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
      //await asyncChange(
      //  addresses,
      //  () => leaderWalletDerivationService.deriveFirstAddressAndSave(wallet),
      //);
      //expect(addresses.length, 20);
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
