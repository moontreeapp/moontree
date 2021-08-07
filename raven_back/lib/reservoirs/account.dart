import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountReservoir<Record, Model> extends Reservoir {
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
