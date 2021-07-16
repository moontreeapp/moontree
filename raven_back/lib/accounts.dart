import 'dart:typed_data';

import 'boxes.dart';
import 'account.dart';
import 'models/account_stored.dart';
import 'cipher.dart';

class Accounts {
  Map<String, Account> accounts = {};
  final Cipher cipher = Cipher(Uint8List.fromList(
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]));

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
