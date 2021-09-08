// dart  test test/unit/reservoirs/account_test.dart

import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/records/records.dart';

import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:reservoir/reservoir.dart';

void main() {
  group('Reservoirs', () {
    late MapSource<Wallet> walletsSource;
    late MapSource<Account> accountsSource;
    late WalletReservoir wallets;
    late AccountReservoir accounts;

    setUp(() {
      walletsSource = MapSource();
      accountsSource = MapSource();
      wallets = WalletReservoir(walletsSource);
      accounts = AccountReservoir(accountsSource);
    });

    test('save a Wallet', () async {
      var encryptedSeed = Uint8List(16);
      var wallet =
          LeaderWallet(id: '0', accountId: 'a0', encryptedSeed: encryptedSeed);
      var wallet2 =
          LeaderWallet(id: '1', accountId: 'a1', encryptedSeed: encryptedSeed);
      await wallets.save(wallet);
      await wallets.save(wallet2);
      expect(wallets.primaryIndex.getOne(wallet.id), wallet);
      expect(wallets.primaryIndex.getOne(wallet2.id), wallet2);
    });
    test('save an Account', () async {
      var account = Account(id: 'a0', name: 'account0', net: Net.Test);
      var account2 = Account(id: 'a1', name: 'account1', net: Net.Test);
      await accounts.save(account);
      await accounts.save(account2);
      expect(accounts.primaryIndex.getOne(account.id), account);
      expect(accounts.primaryIndex.getOne(account2.id), account2);
    });
    test('move wallet', () async {
      var encryptedSeed = Uint8List(16);
      var wallet =
          LeaderWallet(id: '0', accountId: 'a0', encryptedSeed: encryptedSeed);
      var wallet2 =
          LeaderWallet(id: '1', accountId: 'a1', encryptedSeed: encryptedSeed);
      await wallets.save(wallet);
      await wallets.save(wallet2);
      var account = Account(id: 'a0', name: 'account0', net: Net.Test);
      var account2 = Account(id: 'a1', name: 'account1', net: Net.Test);
      await accounts.save(account);
      await accounts.save(account2);

      var wallet1 = wallets.primaryIndex.getOne('0')!;
      var newWallet = LeaderWallet(
          id: wallet1.id,
          accountId: 'a1',
          encryptedSeed: (wallet1 as LeaderWallet).encryptedSeed);
      await wallets.save(newWallet);
      expect(wallets.primaryIndex.getOne('0'), newWallet);
      expect([for (var wall in wallets.byAccount.getAll('a1')) wall.id],
          ['0', '1']);
      expect([for (var wall in wallets.byAccount.getAll('a0')) wall.id], []);
    });
  });
}
