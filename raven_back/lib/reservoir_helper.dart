import 'package:raven/subjects/reservoir.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class ReservoirHelper {
  final Reservoir accounts;
  final Reservoir addresses;

  ReservoirHelper(this.accounts, this.addresses);

  // re-calculates balance for account
  ScripthashBalance calculateBalance(String accountId) {
    return addresses.indices['account']!.getAll(accountId)!.fold(
        ScripthashBalance(0, 0),
        (previousValue, element) => ScripthashBalance(
            previousValue.confirmed + (element as ScripthashBalance).confirmed,
            previousValue.unconfirmed + element.unconfirmed));
  }

  // set the balance for an account
  void setBalance(String accountId, ScripthashBalance balance) {
    // setBalance(accountId, calculateBalance(accountId));
    accounts.data[accountId].balance = balance;
    accounts.save(accountId);
  }
}
