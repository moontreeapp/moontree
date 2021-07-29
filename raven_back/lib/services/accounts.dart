import 'package:raven/models/account.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountsService {
  Reservoir accounts;
  Reservoir addresses;

  AccountsService(this.accounts, this.addresses);

  void init() {
    accounts.changes.listen((change) {
      change.when(added: (added) {
        Account account = added.data;
        addresses.add(account.deriveAddress(0, NodeExposure.Internal));
        addresses.add(account.deriveAddress(0, NodeExposure.External));
      }, updated: (updated) {
        // what's going to change on the account? only the name?
      }, removed: (removed) {
        // - unsubscribe from addresses (scripthash)
        // - delete in-memory addresses
        // - delete in-memory balances, histories, unspents
        // - UI updates
        // - remove from database if it exists
        //   - Truth.instance.removeScripthashesOf(event.value.accountId);
        //   - Truth.instance.accountUnspents.delete(event.value.accountId);
      });
    });
  }
}
