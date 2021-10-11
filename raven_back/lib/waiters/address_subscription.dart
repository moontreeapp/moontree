/// don't forget to empty the backlog when used.

import 'dart:async';

import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'waiter.dart';

/// new address -> put in subscriptionHandles -> setup up subscription
/// new subscriptionHandle -> setup up subscription to blockchain
/// subscription -> retrieve data from blockchain

class AddressSubscriptionWaiter extends Waiter {
  final Map<String, StreamSubscription> subscriptionHandles = {};
  final PublishSubject<Address> addressesNeedingUpdate = PublishSubject();
  final loggedInFlag = false;

  Set<Address> backlogSubscriptions = {};
  Set<Address> backlogRetrievals = {};
  Set<Address> backlogAddressCipher = {};

  Future deinitSubscriptionHandles() async {
    for (var listener in subscriptionHandles.values) {
      await listener.cancel();
    }
    subscriptionHandles.clear();
  }

  void setupClientListener() {
    if (!listeners.keys.contains('subjects.client.stream')) {
      listeners['subjects.client.stream'] =
          subjects.client.stream.listen((client) async {
        if (client == null) {
          await deinitSubscriptionHandles();
        } else {
          backlogSubscriptions.forEach((address) {
            subscribe(client, address);
          });
          backlogSubscriptions.clear();
          if (subscriptionHandles.isEmpty) {
            subscribeToExistingAddresses();
          }
          if (backlogRetrievals.isNotEmpty) {
            retrieve(client, backlogRetrievals.toList());
            backlogRetrievals.clear();
          }
        }
      });
    }
  }

  void setupCipherListener() {
    if (!listeners.keys.contains('subjects.cipher.stream')) {
      listeners['subjects.cipher.stream'] =
          subjects.cipher.stream.listen((cipher) async {
        if (backlogAddressCipher.isNotEmpty) {
          backlogAddressCipher = (await services.wallets.leaders
                  .maybeDeriveNewAddresses(backlogAddressCipher.toList()))
              .toSet();
        }
      });
    }
  }

  void init() {
    setupSubscriptionsListener();
    setupClientListener();
    setupCipherListener();
    setupNewAddressListener();
  }

  void setupSubscriptionsListener() {
    if (!listeners.keys.contains('addressesNeedingUpdate.stream')) {
      listeners['addressesNeedingUpdate.stream'] = addressesNeedingUpdate.stream
          .bufferCountTimeout(10, Duration(milliseconds: 50))
          .listen((changedAddresses) {
        var client = services.client.mostRecentRavenClient;
        if (client == null) {
          for (var address in changedAddresses) {
            backlogRetrievals.add(address);
          }
        } else {
          retrieve(client, changedAddresses);
        }
      });
    }
  }

  void retrieve(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    await services.addresses.saveScripthashHistoryData(
      await services.addresses.getScripthashHistoriesData(
        changedAddresses,
        client,
      ),
    );
  }

  void setupNewAddressListener() {
    if (!listeners.keys.contains('addresses.changes')) {
      listeners['addresses.changes'] =
          addresses.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) {
                Address address = added.data;
                var client = services.client.mostRecentRavenClient;
                if (client == null) {
                  backlogSubscriptions.add(address);
                } else {
                  subscribe(client, address);
                }
              },
              updated: (updated) {},
              removed: (removed) {
                unsubscribe(removed.id as String);
              });
        });
      });
    }
  }

  void subscribe(RavenElectrumClient client, Address address) {
    addressesNeedingUpdate.sink.add(address);
    var stream = client.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressesNeedingUpdate.sink.add(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses() {
    var client = services.client.mostRecentRavenClient;
    for (var address in addresses) {
      if (client == null) {
        backlogSubscriptions.add(address);
      } else {
        subscribe(client, address);
      }
    }
  }
}
