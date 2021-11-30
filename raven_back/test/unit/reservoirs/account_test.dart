// dart  test test/unit/reservoirs/account_test.dart

import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven_back/records/records.dart';

import 'package:raven_back/reservoirs/wallet.dart';
import 'package:raven_back/reservoirs/account.dart';
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
      wallets = WalletReservoir();
      accounts = AccountReservoir();
      wallets.setSource(walletsSource);
      accounts.setSource(accountsSource);
    });

    test('save a Wallet', () async {
      var encryptedEntropy = '00000000000000000000000000000000';
      var wallet = LeaderWallet(
          walletId: '0', accountId: 'a0', encryptedEntropy: encryptedEntropy);
      var wallet2 = LeaderWallet(
          walletId: '1', accountId: 'a1', encryptedEntropy: encryptedEntropy);
      await wallets.save(wallet);
      await wallets.save(wallet2);
      expect(wallets.primaryIndex.getOne(wallet.walletId), wallet);
      expect(wallets.primaryIndex.getOne(wallet2.walletId), wallet2);
    });
    test('save an Account', () async {
      var account = Account(accountId: 'a0', name: 'account0', net: Net.Test);
      var account2 = Account(accountId: 'a1', name: 'account1', net: Net.Test);
      await accounts.save(account);
      await accounts.save(account2);
      expect(accounts.primaryIndex.getOne(account.accountId), account);
      expect(accounts.primaryIndex.getOne(account2.accountId), account2);
    });
    test('move wallet', () async {
      var encryptedEntropy = '00000000000000000000000000000000';
      var wallet = LeaderWallet(
          walletId: '0', accountId: 'a0', encryptedEntropy: encryptedEntropy);
      var wallet2 = LeaderWallet(
          walletId: '1', accountId: 'a1', encryptedEntropy: encryptedEntropy);
      await wallets.save(wallet);
      await wallets.save(wallet2);
      var account = Account(accountId: 'a0', name: 'account0', net: Net.Test);
      var account2 = Account(accountId: 'a1', name: 'account1', net: Net.Test);
      await accounts.save(account);
      await accounts.save(account2);

      var wallet1 = wallets.primaryIndex.getOne('0')!;
      var newWallet = LeaderWallet(
          walletId: wallet1.walletId,
          accountId: 'a1',
          encryptedEntropy: (wallet1 as LeaderWallet).encryptedEntropy);
      await wallets.save(newWallet);
      expect(wallets.primaryIndex.getOne('0'), newWallet);
      expect([for (var wall in wallets.byAccount.getAll('a1')) wall.walletId],
          ['0', '1']);
      expect(
          [for (var wall in wallets.byAccount.getAll('a0')) wall.walletId], []);
    });
  });
}
