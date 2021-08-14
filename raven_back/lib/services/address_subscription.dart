import 'dart:async';

import 'package:raven/reservoirs.dart';
import 'package:raven/records.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/waiters.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class AddressSubscriptionService extends Service {
  AddressReservoir addresses;
  RavenElectrumClient client;
  AddressSubscriptionWaiter addressSubscriptionWaiter;
  LeaderWalletDerivationWaiter leaderWalletDerivationWaiter;
  Map<String, StreamSubscription> subscriptionHandles = {};
  List<StreamSubscription> listeners = [];

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(
    this.addresses,
    this.client,
    this.addressSubscriptionWaiter,
    this.leaderWalletDerivationWaiter,
  ) : super();

  @override
  void init() {
    subscribeToExistingAddresses();
    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      addressSubscriptionWaiter.saveScripthashHistoryData(
        await addressSubscriptionWaiter.getScripthashHistoriesData(
          changedAddresses,
          client,
        ),
      );

      leaderWalletDerivationWaiter.maybeDeriveNewAddresses(changedAddresses);
    }));

    listeners.add(addresses.changes.listen((change) {
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
    }));
  }

  @override
  void deinit() {
    for (var listener in listeners) {
      listener.cancel();
    }
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(Address address) {
    var stream = client.subscribeScripthash(address.scripthash);
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
