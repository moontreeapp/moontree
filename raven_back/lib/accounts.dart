import 'package:raven/account.dart';
import 'package:raven/boxes.dart' as boxes;

class Accounts {
  late Map<String, Account> accounts;

  static final Accounts _singleton = Accounts._();
  static Accounts get instance => _singleton;
  Accounts._();

  /// can we replace with purely reactive listeners?
  Future load() async {
    var accountsBox = boxes.Truth.instance.accounts;
    for (var accountStored in accountsBox.values) {
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
