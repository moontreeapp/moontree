import 'package:reservoir/reservoir.dart';

import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';

class AddressesWaiter extends Waiter {
  AddressReservoir addresses;
  HistoryReservoir histories;

  AddressesWaiter(this.addresses, this.histories) : super();

  @override
  void init() {
    listeners.add(addresses.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {},
            updated: (updated) {},
            removed: (removed) {
              // always triggered by account removal
              histories.removeHistories(removed.id as String);
            });
      });
    }));
  }
}
