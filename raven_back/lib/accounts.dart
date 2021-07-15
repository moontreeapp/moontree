import 'package:raven/account.dart';
import 'boxes.dart';

class Accounts {
  Map<String, Account> accounts = {};

  static final Accounts _singleton = Accounts._();
  static Accounts get instance => _singleton;
  Accounts._();

  /// can we replace with purely reactive listeners?
  Future load() async {
    for (var accountStored in Truth.instance.accounts.values) {
      addAccountStored(accountStored);
    }
  }

  void addAccountStored(AccountStored accountStored) {
    var account = Account.fromAccountStored(accountStored);
    addAccount(account);
  }

  void addAccount(Account account) {
    accounts[account.accountId] = account;
  }
}
