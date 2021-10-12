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
          subscribe(client as RavenElectrumClient, address);
        });
        backlogSubscriptions.clear();
        if (subscriptionHandles.isEmpty) {
          subscribeToExistingAddresses();
        }
        if (backlogRetrievals.isNotEmpty) {
          unawaited(retrieveAndMakeNewAddress(
              client as RavenElectrumClient, backlogRetrievals.toList()));
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
    await retrieve(client, changedAddresses);
    for (var changedAddress in changedAddresses) {
      var wallet = changedAddress.wallet!;
      if (wallet.humanTypeKey == LingoKey.leaderWalletType) {
        if (cipherRegistry.ciphers.keys.contains(wallet.cipherUpdate)) {
          services.wallets.leaders.maybeSaveNewAddress(
              wallet as LeaderWallet,
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
