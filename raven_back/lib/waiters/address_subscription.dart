import 'dart:async';

import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'waiter.dart';

class AddressSubscriptionWaiter extends Waiter {
  final Map<String, StreamSubscription> subscriptionHandles = {};
  final PublishSubject<Address> addressesNeedingUpdate = PublishSubject();
  final loggedInFlag = false;

  void init() {
    subjects.clientAndLogin.stream.listen((clientAndLogin) async {
      if (clientAndLogin.client == null ||
          (services.passwords.passwordRequired &&
              clientAndLogin.login == false)) {
        await deinit();
      } else {
        setupListeners(clientAndLogin.client!);
      }
    });
  }

  void setupListeners(RavenElectrumClient ravenClient) {
    subscribeToExistingAddresses(ravenClient);
    if (!listeners.keys.contains('addressesNeedingUpdate.stream')) {
      listeners['addressesNeedingUpdate.stream'] = addressesNeedingUpdate.stream
          .bufferCountTimeout(10, Duration(milliseconds: 50))
          .listen((changedAddresses) async {
        await services.addresses.saveScripthashHistoryData(
          await services.addresses.getScripthashHistoriesData(
            changedAddresses,
            ravenClient,
          ),
        );
        services.wallets.leaders.maybeDeriveNewAddresses(changedAddresses);
      });
    }
    // if ( stream has not already been listened to)..
    if (!listeners.keys.contains('addresses.changes')) {
      listeners['addresses.changes'] =
          addresses.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) {
                Address address = added.data;
                addressNeedsUpdating(address);
                subscribe(ravenClient, address);
              },
              updated: (updated) {},
              removed: (removed) {
                unsubscribe(removed.id as String);
              });
        });
      });
    }
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(RavenElectrumClient ravenClient, Address address) {
    var stream = ravenClient.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses(RavenElectrumClient ravenClient) {
    for (var address in addresses) {
      subscribe(ravenClient, address);
    }
  }
}
