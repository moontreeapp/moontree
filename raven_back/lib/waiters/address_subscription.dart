import 'dart:async';

import 'package:raven/utils/lookup.dart';
import 'package:raven/utils/transform.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'waiter.dart';

//class MapGet extends Map<Tkey, Tvalue> {
//  Tvalue? get(key) => containsKey(key) ? map[key] : null;
//}

class AddressSubscriptionWaiter extends Waiter {
  final Map<String, StreamSubscription> subscriptionHandles = {};
  final StreamController<Address> addressesNeedingUpdate = StreamController();
  final loggedInFlag = false;

  void init() {
    // if we setup a password... resetup listeners...
    if (services.passwords.usingPassword) {
      subjects.clientAndLogin.stream.listen((clientAndLogin) {
        // one
        mapGet(
            clientAndLogin.toString(),
            mapMap(clientAndLogin.matrix, {
              0: deinit,
              1: deinit,
              2: deinit,
              3: setupListeners,
              4: (_) {},
              5: setupListeners
            }) as Map<String, Function>)(clientAndLogin.client);

        // two
        if (clientAndLogin.client == null) {
          deinit();
        } else {
          if (clientAndLogin.login != false) {
            setupListeners(clientAndLogin.client!);
          }
        }
      });
    } else {
      subjects.client.stream.listen((ravenClient) {
        if (ravenClient == null) {
          deinit();
        } else {
          setupListeners(ravenClient);
        }
      });
    }
  }

  void setupListeners(RavenElectrumClient ravenClient) {
    subscribeToExistingAddresses(ravenClient);
    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      await services.addresses.saveScripthashHistoryData(
        await services.addresses.getScripthashHistoriesData(
          changedAddresses,
          ravenClient,
        ),
      );

      // if logged in
      services.wallets.leaders.maybeDeriveNewAddresses(changedAddresses);
    }));

    listeners.add(addresses.changes.listen((List<Change> changes) {
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
    }));
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
