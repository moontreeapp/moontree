import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountReservoir<Record, Model> extends Reservoir {
  AccountReservoir(source, getPrimaryKey, [mapToModel, mapToRecord])
      : super(source, getPrimaryKey, [mapToModel, mapToRecord]);

  // set the balance for an account
  void setBalance(String accountId, Balance balance) {
    data[accountId].balance = balance;
    save(accountId);
  }
}
