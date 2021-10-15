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
  Set<Address> backlogWalletsToUpdate = {};

  Future deinitSubscriptionHandles() async {
    for (var listener in subscriptionHandles.values) {
      await listener.cancel();
    }
    subscriptionHandles.clear();
  }

  void setupClientListener() {
    listen('subjects.client.stream', subjects.client.stream, (client) async {
      if (client == null) {
        await deinitSubscriptionHandles();
      } else {
        backlogSubscriptions.forEach((address) {
          if (!subscriptionHandles.keys.contains(address.addressId)) {
            subscribe(client as RavenElectrumClient, address);
          }
        });
        backlogSubscriptions.clear();
        subscribeToExistingAddresses(client as RavenElectrumClient);
        if (backlogRetrievals.isNotEmpty) {
          unawaited(
              retrieveAndMakeNewAddress(client, backlogRetrievals.toList()));
          backlogRetrievals.clear();
        }
      }
    });
  }

  void setupCipherListener() {
    listen('subjects.cipher.stream', subjects.cipher.stream, (cipher) async {
      if (backlogAddressCipher.isNotEmpty) {
        var temp = <Address>{};
        for (var changedAddress in backlogAddressCipher) {
          var wallet = changedAddress.wallet!;
          if (cipherRegistry.ciphers.keys.contains(wallet.cipherUpdate)) {
            services.wallets.leaders.maybeSaveNewAddress(
                wallet as LeaderWallet,
                cipherRegistry.ciphers[wallet.cipherUpdate]!,
                changedAddress.exposure);
          } else {
            temp.add(changedAddress);
          }
        }
        backlogAddressCipher = temp;
      }
    });
  }

  void init() {
    setupSubscriptionsListener();
    setupClientListener();
    setupCipherListener();
    setupNewAddressListener();
  }

  void setupSubscriptionsListener() {
    listen(
        'addressesNeedingUpdate',
        addressesNeedingUpdate.stream.bufferCountTimeout(
            10, Duration(milliseconds: 50)), (changedAddresses) {
      print('listen(addressesNeedingUpdate): ${[
        for (Address ca in changedAddresses as List<Address>) ca.address
      ]}');
      var client = services.client.mostRecentRavenClient;
      if (client == null) {
        for (var address in changedAddresses as List<Address>) {
          backlogRetrievals.add(address);
        }
      } else {
        retrieveAndMakeNewAddress(client, changedAddresses as List<Address>);
      }
    });
  }

  Future retrieveAndMakeNewAddress(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    print('retrieving: ${[
      for (Address ca in changedAddresses as List<Address>) ca.address
    ]}');
    await retrieve(client, changedAddresses);
    for (var changedAddress in changedAddresses) {
      var wallet = changedAddress.wallet!;
      if (wallet is LeaderWallet) {
        if (cipherRegistry.ciphers.keys.contains(wallet.cipherUpdate)) {
          services.wallets.leaders.maybeSaveNewAddress(
              wallet,
              cipherRegistry.ciphers[wallet.cipherUpdate]!,
              changedAddress.exposure);
        } else {
          backlogAddressCipher.add(changedAddress);
        }
      }
    }
  }

  Future retrieve(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    await services.addresses.saveScripthashHistoryData(
      await services.addresses.getScripthashHistoriesData(
        changedAddresses,
        client,
      ),
    );
  }

  void setupNewAddressListener() {
    listen('addresses.changes', addresses.changes, (List<Change> changes) {
      changes.forEach((change) {
        change.when(
            added: (added) {
              Address address = added.data;
              print('setupNewAddressListener:${address.address}');
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

  void subscribe(RavenElectrumClient client, Address address) {
    // we get a status back as soon as we subscribe... so we don't need to do it here.
    //addressesNeedingUpdate.sink.add(address);
    var stream = client.subscribeScripthash(address.addressId);
    subscriptionHandles[address.addressId] = stream.listen((status) {
      print('listen(subscribe): ${address.address}');
      addressesNeedingUpdate.sink.add(address);
    });
  }

  void unsubscribe(String addressId) {
    subscriptionHandles[addressId]!.cancel();
  }

  void subscribeToExistingAddresses(RavenElectrumClient client) {
    for (var address in addresses) {
      if (!subscriptionHandles.keys.contains(address.addressId)) {
        /// the only time this is called is when a client has been broadcast
        //if (client == null) {
        //  print('subscribeToExistingAddresses:BACKLOG:${address.addressId}');
        //  backlogSubscriptions.add(address);
        //} else {
        print('subscribeToExistingAddresses:SUBSCIRBE:${address.address}');
        subscribe(client, address);
        //}
      }
    }
  }
}
