import 'dart:async';

import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'waiter.dart';

class AddressSubscriptionWaiter extends Waiter {
  final Map<String, StreamSubscription> subscriptionHandles = {};
  final StreamController<Address> addressesNeedingUpdate = StreamController();

  RavenElectrumClient? client;

  void init(RavenElectrumClient client) {
    this.client = client;

    subscribeToExistingAddresses();
    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      await services.addresses.saveScripthashHistoryData(
        await services.addresses.getScripthashHistoriesData(
          changedAddresses,
          client,
        ),
      );

      services.wallets.leaders.maybeDeriveNewAddresses(changedAddresses);
    }));

    listeners.add(addresses.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              Address address = added.data;
              addressNeedsUpdating(address);
              subscribe(address);
            },
            updated: (updated) {},
            removed: (removed) {
              unsubscribe(removed.id as String);
            });
      });
    }));
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(Address address) {
    var stream = client!.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses() {
    for (var address in addresses) {
      subscribe(address);
    }
  }
}
