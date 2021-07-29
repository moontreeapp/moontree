import 'dart:typed_data';

import 'boxes.dart';
import '../models/account.dart';
import '../records.dart' as records;
import '../cipher.dart';

class Accounts {
  Map<String, Account> accounts = {};
  final Cipher cipher = NoCipher();

  static final Accounts _singleton = Accounts._();
  static Accounts get instance => _singleton;
  Accounts._();

  /// can we replace with purely reactive listeners?
  Future load() async {
    for (var accountStored in Truth.instance.accounts.values) {
      addAccountStored(accountStored);
    }
  }

  void addAccountStored(records.Account record) {
    var account = Account.fromRecord(record, cipher: cipher);
    addAccount(account);
  }

  void addAccount(Account account) {
    accounts[account.accountId] = account;
  }
}
