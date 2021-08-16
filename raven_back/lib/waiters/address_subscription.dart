import 'dart:async';

import 'package:raven/reservoirs.dart';
import 'package:raven/records.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/services.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class AddressSubscriptionWaiter extends Waiter {
  AddressReservoir addresses;
  RavenElectrumClient client;
  AddressSubscriptionService addressSubscriptionService;
  LeaderWalletDerivationService leaderWalletDerivationService;
  Map<String, StreamSubscription> subscriptionHandles = {};
  List<StreamSubscription> listeners = [];

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionWaiter(
    this.addresses,
    this.client,
    this.addressSubscriptionService,
    this.leaderWalletDerivationService,
  ) : super();

  @override
  void init() {
    subscribeToExistingAddresses();
    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      addressSubscriptionService.saveScripthashHistoryData(
        await addressSubscriptionService.getScripthashHistoriesData(
          changedAddresses,
          client,
        ),
      );

      leaderWalletDerivationService.maybeDeriveNewAddresses(changedAddresses);
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
