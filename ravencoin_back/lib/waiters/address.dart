import 'package:ravencoin_back/ravencoin_back.dart';
import 'waiter.dart';

class AddressWaiter extends Waiter {
  void init() {
    listen(
      'addresses.changes',
      pros.addresses.changes,
      (Change<Address> change) => handleAddressChange(change),
    );
  }

  void handleAddressChange(Change<Address> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) {
          var address = added.data;
          services.client.subscribe.toAddress(address);
        },
        updated: (updated) => services.client.subscribe.toAddress(updated.data),
        removed: (removed) {
          var address = removed.data;
          services.client.subscribe.unsubscribeAddress(address.id);
          //removed.id as String);

          /// could be moved to waiter on transactions...
          pros.vouts.removeAll(address.vouts.map((vout) => vout).toList());

          /// no way to join on this:
          //vins.removeAll(address.vins.map((vin) => vin).toList());
        });
  }
}
