import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';

import 'waiter.dart';

class AddressWaiter extends Waiter {
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
