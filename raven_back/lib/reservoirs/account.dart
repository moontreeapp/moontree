import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountReservoir<Record, Model> extends Reservoir {
  AccountReservoir() : super(HiveSource('accounts')) {
    addPrimaryIndex((account) => account.accountId);
  }

  // set the balance for an account
  void setBalance(String accountId, Balance balance) {
    primaryIndex.getOne(accountId).balance = balance;
    save(accountId);
  }
}
