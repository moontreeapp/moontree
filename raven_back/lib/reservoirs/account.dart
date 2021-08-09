import 'package:raven/models/account.dart';
import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/records.dart' as records;

class AccountReservoir extends Reservoir<String, records.Account, Account> {
  AccountReservoir() : super(HiveSource('accounts')) {
    addPrimaryIndex((account) => account.accountId);
  }

  void setBalance(String accountId, String ticker, Balance balance) {
    var account = primaryIndex.getOne(accountId).balances[ticker] = balance;
    // Question: save takes an account not an account Id, does it replace the existing acccount?
    //save(accountId);
    save(account);
  }
}
