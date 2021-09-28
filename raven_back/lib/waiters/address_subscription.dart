/// don't forget to empty the backlog when used.

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

  Set<Address> backlogSubscriptions = {};
  Set<Address> backlogRetrievals = {};
  Set<Address> backlogAddressCipher = {};

  void clientListener() {
    if (!listeners.keys.contains('subjects.client.stream')) {
      listeners['subjects.client.stream'] =
          subjects.client.stream.listen((client) async {
        if (client == null) {
          //deinit (cancel and remove) all subscriptions
          await deinit();
        } else {
          //if not inited, init
          if (listeners.keys.isEmpty) {
            clientListener(); //?
            cipherListener(); //?
            subscribeToExistingAddresses();
          }
          if (backlogSubscriptions.isNotEmpty) {
            backlogSubscriptions.forEach((address) {
              subscribe(client, address);
            });
          }
          if (backlogRetrievals.isNotEmpty) {
            retrieve(client, backlogRetrievals.toList());
          }
        }
      });
    }
  }

  void cipherListener() {
    if (!listeners.keys.contains('subjects.cipher.stream')) {
      listeners['subjects.cipher.stream'] =
          subjects.cipher.stream.listen((cipher) async {
        if (backlogAddressCipher.isNotEmpty) {
          // assume full???
          services.wallets.leaders
              .maybeDeriveNewAddresses(cipher, backlogAddressCipher);
        }
        if (backlogRetrievals.isNotEmpty) {
          retrieve(cipher, backlogRetrievals.toList());
        }
      });
    }
  }

/*

  when we see a new address get created we start subscribing to it on the blockchain.
    easy - need 2 listeners, client and addresses, make a backlog 

  when we get a trigger from the blockchain about this address...
    get the change from ravenClient
      if it doesn't exist currently... first of all how did you get the notification? but maybe it just barely went down...
        then make a backlog for that and check it as well on the client listener.
      else
        just get the data like normal. 

*/

  void init() {
    subscribeToExistingAddresses();
    setupSubscriptionsListener();
    setupNewAddressListener();
    subjects.client.stream.listen((client) async {
      if (client == null) {
        await deinit();
      } else {
        'pass';
      }
    });
  }

  //void asdf() {
  //  subjects.cipher.stream.listen((client) async {
  //    if (client == null ) {
  //      await deinit();
  //    } else {
  //      'pass';
  //    }
  //  }
  //}

  void setupSubscriptionsListener() {
    if (!listeners.keys.contains('addressesNeedingUpdate.stream')) {
      listeners['addressesNeedingUpdate.stream'] = addressesNeedingUpdate.stream
          .bufferCountTimeout(10, Duration(milliseconds: 50))
          .listen((changedAddresses) async {
        var ravenClient = await subjects.client.last;
        if (ravenClient == null) {
          for (var address in changedAddresses) {
            backlogRetrievals.add(address);
          }
        } else {
          retrieve(ravenClient, changedAddresses);
        }

        ///if ciphers ...
        ///// requires ciphers...
        //services.wallets.leaders.maybeDeriveNewAddresses(changedAddresses);
        // else
        // backlogAddressestosee if you have to create new addresses on wallet...add(...changedAddresses)
        //backlogAddressCipher.addAll(changedAddresses);
      });
    }
  }

  void retrieve(
      RavenElectrumClient ravenClient, List<Address> changedAddresses) async {
    await services.addresses.saveScripthashHistoryData(
      await services.addresses.getScripthashHistoriesData(
        changedAddresses,
        ravenClient,
      ),
    );
  }

  void setupNewAddressListener() {
    // if ( stream has not already been listened to)..
    if (!listeners.keys.contains('addresses.changes')) {
      listeners['addresses.changes'] =
          addresses.changes.listen((List<Change> changes) {
        changes.forEach((change) {
          change.when(
              added: (added) async {
                Address address = added.data;
                var ravenClient = await subjects.client.last;
                if (ravenClient == null) {
                  backlogSubscriptions.add(address);
                } else {
                  //addressNeedsUpdating(address); // happens in subscribe
                  subscribe(ravenClient, address);
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

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(RavenElectrumClient ravenClient, Address address) async {
    var stream = ravenClient.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses() {
    for (var address in addresses) {
      //subscribe(address);
      backlogSubscriptions.add(address);
    }
  }
}
