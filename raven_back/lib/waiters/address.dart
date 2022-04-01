import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AddressWaiter extends Waiter {
  void init() {
    listen(
      'addresses.changes',
      res.addresses.changes,
      (Change<Address> change) => handleAddressChange(change),
    );
  }

  void handleAddressChange(Change<Address> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) {
          services.client.subscribe.to(added.data);
        },
        updated: (updated) => services.client.subscribe.to(updated.data),
        removed: (removed) {
          var address = removed.data;
          services.client.subscribe.unsubscribe(address.id);
          //removed.id as String);

          /// could be moved to waiter on transactions...
          res.vouts.removeAll(address.vouts.map((vout) => vout).toList());

          /// no way to join on this:
          //vins.removeAll(address.vins.map((vin) => vin).toList());
        });
  }
}
