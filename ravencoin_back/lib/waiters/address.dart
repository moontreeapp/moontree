import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

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
        added: (added) async =>
            await services.client.subscribe.toAddress(added.record),
        updated: (updated) async =>
            await services.client.subscribe.toAddress(updated.record),
        removed: (removed) async {
          var address = removed.record;
          services.client.subscribe.unsubscribeAddress(address);
          //removed.id as String);

          /// could be moved to waiter on transactions...
          await pros.vouts
              .removeAll(address.vouts.map((vout) => vout).toList());

          /// no way to join on this:
          //vins.removeAll(address.vins.map((vin) => vin).toList());
        });
  }
}
