import 'package:moontree_utils/moontree_utils.dart' show Trigger;
import 'package:client_back/client_back.dart';

class AddressWaiter extends Trigger {
  void init() {
    when(
      thereIsA: pros.addresses.changes,
      doThis: handleAddressChange,
    );
  }

  void handleAddressChange(Change<Address> change) {
    change.when(
        loaded: (Loaded<Address> loaded) {},
        added: (Added<Address> added) async =>
            services.client.subscribe.toAddress(added.record),
        updated: (Updated<Address> updated) async =>
            services.client.subscribe.toAddress(updated.record),
        removed: (Removed<Address> removed) async {
          final Address address = removed.record;
          services.client.subscribe.unsubscribeAddress(address);
          //removed.id as String);

          /// could be moved to waiter on transactions...
          await pros.vouts
              .removeAll(address.vouts.map((Vout vout) => vout).toList());

          /// no way to join on this:
          //vins.removeAll(address.vins.map((vin) => vin).toList());
        });
  }
}
