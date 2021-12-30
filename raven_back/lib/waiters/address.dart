import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AddressWaiter extends Waiter {
  Set<Change<Address>> backlog = {};

  /// these two listeners follow the 'backlog' pattern in the event that we're
  /// ready to derive addresses on a newly created wallet, but we have no
  /// electrum client connection available. we might be able to use a "combine
  /// latest" plus full replay subjects to achieve the same thing directly in
  /// streams themselves. account.dart waiter may be a good example of that.
  /// Yet, a proliferation of streams comes with some small overhead and the
  /// backlog pattern is simple, even though split accross multiple listeners:

  void init() {
    listen(
      'addresses.changes',
      addresses.changes,
      (Change<Address> change) {
        if (streams.client.client.value == null ||
            !streams.client.connected.value) {
          backlog.add(change);
        } else {
          handleAddressChange(change);
        }
      },
      autoDeinit: true,
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) {
        if (connected) {
          backlog
              .forEach((Change<Address> change) => handleAddressChange(change));
          backlog.clear();
        }
      },
      autoDeinit: true,
    );
  }

  void handleAddressChange(Change<Address> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) {
          services.client.subscribe.toExistingAddresses();
        },
        updated: (updated) {
          services.client.subscribe.toExistingAddresses();
        },
        removed: (removed) {
          var address = removed.data;
          // could be moved to waiter on transactions...
          vouts.removeAll(address.vouts.map((vout) => vout).toList());
          //vins.removeAll(address.vins.map((vin) => vin).toList()); // no way to join on it...
        });
  }
}
