import 'package:raven/models/address.dart';
import 'package:raven/reservoir/reservoir.dart';

import 'reservoir_helper.dart';

class AddressesService {
  Reservoir addresses;
  ReservoirHelper resHelper;

  AddressesService(this.addresses, this.resHelper);

  void init() {
    //AddressSubscriptionService(accounts, addresses, client);
    addresses.changes.listen((change) {
      change.when(added: (added) {
        // pass - see AddressSubscriptionService
      }, updated: (updated) {
        Address address = updated.data;
        resHelper.setBalance(
            address.accountId, resHelper.calculateBalance(address.accountId));
      }, removed: (removed) {
        // always happens because account was removed...
        // delete in-memory balances, histories, unspents
        // TODO

        // UI updates
        // TODO
      });
    });
  }
}
