import 'dart:typed_data';

import 'boxes.dart';
import 'account.dart';
import 'models/account_stored.dart';
import 'cipher.dart';

class Accounts {
  Map<String, Account> accounts = {};
  final Cipher cipher = Cipher([1, 2, 3] as Uint8List);

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
    var account = Account.fromAccountStored(accountStored, cipher);
    addAccount(account);
  }

  void addAccount(Account account) {
    accounts[account.accountId] = account;
  }
}
