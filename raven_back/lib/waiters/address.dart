import 'package:raven/raven.dart';

import 'waiter.dart';

class AddressWaiter extends Waiter {
  void init() {
    listen('addresses.batchedChanges', addresses.batchedChanges,
        (List<Change<Address>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {},
            updated: (updated) {},
            removed: (removed) {
              var address = removed.data;
              // could be moved to waiter on transactions...
              vouts.removeAll(address.vouts.map((vout) => vout).toList());
              //vins.removeAll(address.vins.map((vin) => vin).toList()); // no way to join on it...
            });
      });
    });
  }
}
