import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class AddressWaiter extends Waiter {
  void init() {
    listen('addresses.changes', addresses.changes, (List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {},
            updated: (updated) {},
            removed: (removed) {
              Address address = removed.data;
              transactions
                  .removeAll(address.transactions.map((tx) => tx).toList());
              // could be moved to waiter on transactions...
              vouts.removeAll(address.vouts.map((vout) => vout).toList());
              vins.removeAll(address.vins.map((vin) => vin).toList());
            });
      });
    });
  }
}
