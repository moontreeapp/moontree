import 'package:raven/raven.dart';

class AccountService {
  /// removes account if...
  /// no wallets assigned to it, and it's not the only account.
  /// if it's the current or preferred account, reassign
  Future<void> removeAccount(String accountId) async {
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

  Future<Account> makeSaveAccount(String name,
      {Net net = Net.Test, String? accountId}) async {
    var account = newAccount(name, net: net);
    await accounts.save(account);
    return account;
  }
}
