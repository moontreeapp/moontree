import 'package:raven/models.dart';
import 'package:raven/models/balances.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountReservoir<Record, Model> extends Reservoir {
  AccountReservoir([source, mapToModel, mapToRecord])
      : super(source ?? HiveBoxSource('accounts'), (account) => account.name,
            [mapToModel, mapToRecord]);

  // set the balance for an account
  void setBalances(String accountId, Balances balances) {
    data[accountId].balances = balances;
    save(accountId);
  }
}
