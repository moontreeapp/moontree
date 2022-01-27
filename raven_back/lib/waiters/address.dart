import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AddressWaiter extends Waiter {
  Set<Address> backlog = {};

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
      res.addresses.changes,
      (Change<Address> change) => handleAddressChange(change),
      autoDeinit: true,
    );

    listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) {
        if (connected) {
          subscribeToBacklog();

          /// everytime we get a connected message
          /// just make sure you're subscribed to all addresses:
          var unhandledAddresses =
              services.client.subscribe.toExistingAddresses();
          backlog.addAll(unhandledAddresses);
        }
      },
      autoDeinit: true,
    );
  }

  void handleAddressChange(Change<Address> change) {
    change.when(
        loaded: (loaded) {},
        added: (added) => subscribeTo(added.data),
        updated: (updated) => subscribeTo(updated.data),
        removed: (removed) {
          var address = removed.data;
          services.client.subscribe.unsubscribe(address.addressId);
          //removed.id as String);

          /// could be moved to waiter on transactions...
          res.vouts.removeAll(address.vouts.map((vout) => vout).toList());

          /// no way to join on this:
          //vins.removeAll(address.vins.map((vin) => vin).toList());
        });
  }

  void subscribeToBacklog() {
    var returnToBacklog = <Address>{};
    for (var address in backlog) {
      if (!services.client.subscribe.to(address)) {
        returnToBacklog.add(address);
      }
    }
    backlog = returnToBacklog;
  }

  void subscribeTo(Address address) {
    if (!services.client.subscribe.to(address)) {
      backlog.add(address);
    } else {
      backlog.remove(address);
    }
  }
}
