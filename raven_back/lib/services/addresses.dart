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
        // if this happens its because the account has been removed...
        // so do the removal steps that make sense here.
      });
    });
  }
}
