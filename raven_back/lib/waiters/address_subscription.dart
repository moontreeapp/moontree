import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/stream/buffer_count_window.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:rxdart/src/transformers/distinct_unique.dart';

import 'waiter.dart';

/// new address -> put in subscriptionHandles -> setup up subscription
/// new subscriptionHandle -> setup up subscription to blockchain
/// subscription -> retrieve data from blockchain

class AddressSubscriptionWaiter extends Waiter {
  final loggedInFlag = false;
  late int id = 0;

  Set<Address> backlogSubscriptions = {};
  Set<Address> backlogRetrievals = {};
  Set<Address> backlogWalletsToUpdate = {};

  void init() {
    setupSubscriptionsListener();
    setupClientListener();
    setupNewAddressListener();
  }

  Future deinitSubscriptionHandles() async {
    for (var listener in services.client.subscribe.subscriptionHandles.values) {
      await listener.cancel();
    }
    services.client.subscribe.subscriptionHandles.clear();
  }

  void setupClientListener() =>
      listen('streams.client.client', streams.client.client, (client) async {
        if (client == null) {
          await deinitSubscriptionHandles();
        } else {
          backlogSubscriptions.forEach((address) {
            if (!services.client.subscribe.subscriptionHandles.keys
                .contains(address.addressId)) {
              services.client.subscribe
                  .to(client as RavenElectrumClient, address);
            }
          });
          backlogSubscriptions.clear();
          services.client.subscribe
              .toExistingAddresses(client as RavenElectrumClient);
          if (backlogRetrievals.isNotEmpty) {
            for (var address in backlogRetrievals) {
              unawaited(retrieveAndMakeNewAddress(client, address));
            }
            backlogRetrievals.clear();
          }
        }
      });

  void setupSubscriptionsListener() => listen(
          'addressesNeedingUpdate',

          /// we end up handling these one at a time so why buffer them?
          // services.client.subscribe.addressesNeedingUpdate.stream
          //     .bufferCountTimeout(10, Duration(milliseconds: 50)),
          // (changedAddresses) {
          services.client.subscribe.addressesNeedingUpdate.stream,
          (Address address) {
        var client = streams.client.client.value;
        if (client == null) {
          backlogRetrievals.add(address);
        } else {
          unawaited(retrieveAndMakeNewAddress(client, address));
        }
      });

  void setupNewAddressListener() =>
      listen('addresses.batchedChanges', addresses.batchedChanges,
          (List<Change> batchedChanges) {
        batchedChanges.forEach((change) {
          change.when(
              loaded: (loaded) {},
              added: (added) async {
                Address address = added.data;
                // todo - move this into the stream:
                //if (address.account!.net ==
                //    settings.primaryIndex
                //        .getOne(SettingName.Electrum_Net)!
                //        .value) {
                if (true) {
                  var client = streams.client.client.value;
                  if (client == null) {
                    backlogSubscriptions.add(address);
                  } else {
                    services.client.subscribe.to(client, address);
                  }
                }
              },
              updated: (updated) {},
              removed: (removed) {
                services.client.subscribe.unsubscribe(removed.id as String);
              });
        });
      });

  Future retrieveAndMakeNewAddress(
    RavenElectrumClient client,
    Address address,
  ) async {
    var msg = 'Downloading transactions for ${address.address}';
    services.busy.clientOn(msg);
    await services.address.getAndSaveTransactionsByAddresses(address, client);
    services.busy.clientOff(msg);
  }
}
