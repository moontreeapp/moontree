import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';

part 'wallet.keys.dart';

class WalletReservoir extends Reservoir<_IdKey, Wallet> {
  late IndexMultiple<_AccountKey, Wallet> byAccount; // causes error:

  /*
  I/flutter ( 8220): print(accounts.data)
    Account(0, Primary, Net.Test), 
    Account(1, Savings, Net.Test), 
    Account(2, asdf, Net.Test), 
    Account(3, test, Net.Test)
  I/flutter ( 8220): print(wallets.data)
    LeaderWallet(miF2WPWJupMDSoPNCCYMEkC1DLdYLtU39A, 0, [195, 31, 193, 45, 175, 212]),
    LeaderWallet(mrviqPHaeANNFvjY84xVQdZrT6MtAkz9yK, 1, [101, 45, 70, 66, 209, 16]),
    LeaderWallet(mwWq1RLX9HxyRmD2ejEmhEnPJyfWwU9zxQ, 3, [198, 168, 30, 232, 152, 129]),
    LeaderWallet(n1BuaCRqhZSKwpKjofQBjdTR7e9JPq7tAp, 2, [182, 178, 57, 89, 154, 214])
  I/flutter ( 8220): print([
      ...[account.id for account in accounts,
      ...[ wallets.byAccount.getAll(account.id)]]])
    [0, miF2WPWJupMDSoPNCCYMEkC1DLdYLtU39A,
    1, mrviqPHaeANNFvjY84xVQdZrT6MtAkz9yK, 
    2, n1BuaCRqhZSKwpKjofQBjdTR7e9JPq7tAp, 
    3, mwWq1RLX9HxyRmD2ejEmhEnPJyfWwU9zxQ, n1BuaCRqhZSKwpKjofQBjdTR7e9JPq7tAp // duplicated
  ]  
  */

  WalletReservoir([source]) : super(source ?? HiveSource('wallets'), _IdKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }
}
