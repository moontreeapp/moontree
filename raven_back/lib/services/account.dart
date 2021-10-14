import 'package:ravencoin/ravencoin.dart';

import 'package:raven/raven.dart';

class AccountService {
  /// removes account if...
  /// no wallets assigned to it, and it's not the only account.
  /// if it's the current or preferred account, reassign
  Future<void> remove(String accountId) async {
    var account = accounts.primaryIndex.getOne(accountId);
    if (account != null &&
        accounts.data.length > 1 &&
        wallets.byAccount.getAll(accountId).isEmpty) {
      //accounts.primaryIndex.remove(account); //required?
      await accounts.remove(account);
      if (account.accountId == settings.currentAccountId) {
        var newCurrentAccount = accounts.primaryIndex.getAny()!;
        await settings.setCurrentAccountId(newCurrentAccount.accountId);
      }
      if (account.accountId == settings.preferredAccountId) {
        var newPreferredAccount = accounts.primaryIndex.getAny()!;
        await settings.savePreferredAccountId(newPreferredAccount.accountId);
      }
    }
  }

  Account newAccount(String name, {Net net = Net.Test, String? accountId}) {
    if (accountId != null) {
      var account = accounts.primaryIndex.getOne(accountId);
      if (account != null) {
        return account;
      }
    }
    return Account(
        accountId: accounts.data.length.toString(), name: name, net: net);
  }

  Future<Account> createSave(String name,
      {Net net = Net.Test, String? accountId}) async {
    var account = newAccount(name, net: net, accountId: accountId);
    await accounts.save(account);
    return account;
  }

  /// Return a WalletBase suitable for sending assets back to self during a
  /// `send` transaction.
  ///
  /// Try getting a LeaderWallet change wallet first, then a SingleWallet if
  /// not available. LeaderWallets are better, because they can provide a shade
  /// of anonymity.
  WalletBase getChangeWallet(Account account) {
    for (var wallet in account.leaderWallets) {
      return services.wallets.leaders.getNextEmptyWallet(wallet);
    }
    for (var wallet in account.singleWallets) {
      return services.wallets.singles.getKPWallet(wallet);
    }
    throw WalletMissing("Account '${account.accountId}' has no change wallets");
  }
}
