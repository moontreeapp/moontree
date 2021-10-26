/// don't forget to empty the backlog when used.

import 'dart:async';

import 'package:raven/records/cipher.dart';
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
    listen('ciphers.batchedChanges', ciphers.batchedChanges,
        (List<Change<Cipher>> batchedChanges) async {
      if (backlogAddressCipher.isNotEmpty) {
        var temp = <Address>{};
        for (var changedAddress in backlogAddressCipher) {
          var wallet = changedAddress.wallet!;
          if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
            services.wallet.leader.maybeSaveNewAddress(
                wallet as LeaderWallet,
                ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
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
      var client = services.client.mostRecentRavenClient;
      if (client == null) {
        for (var address in changedAddresses as List<Address>) {
          backlogRetrievals.add(address);
        }
      } else {
        unawaited(retrieveAndMakeNewAddress(
            client, changedAddresses as List<Address>));
      }
    });
  }

  Future retrieveAndMakeNewAddress(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    await retrieve(client, changedAddresses);
    for (var changedAddress in changedAddresses) {
      var wallet = changedAddress.wallet!;
      if (wallet is LeaderWallet) {
        if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
          services.wallet.leader.maybeSaveNewAddress(
              wallet,
              ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
              changedAddress.exposure);
        } else {
          backlogAddressCipher.add(changedAddress);
        }
      }
    }
  }

  Future retrieve(
      RavenElectrumClient client, List<Address> changedAddresses) async {
    await services.address.getAndSaveTransaction(
      changedAddresses,
      client,
    );
  }

  void setupNewAddressListener() {
    listen('addresses.batchedChanges', addresses.batchedChanges,
        (List<Change> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
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

  void subscribe(RavenElectrumClient client, Address address) {
    // we get a status back as soon as we subscribe... so we don't need to do it here.
    //addressesNeedingUpdate.sink.add(address);
    var stream = client.subscribeScripthash(address.addressId);
    subscriptionHandles[address.addressId] = stream.listen((status) {
      addressesNeedingUpdate.sink.add(address);
    });
  }

  void unsubscribe(String addressId) {
    subscriptionHandles[addressId]!.cancel();
  }

  void subscribeToExistingAddresses(RavenElectrumClient client) {
    for (var address in addresses) {
      if (!subscriptionHandles.keys.contains(address.addressId)) {
        subscribe(client, address);
      }
    }
  }
}
