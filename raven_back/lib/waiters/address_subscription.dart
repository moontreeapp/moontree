import 'dart:async';
import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AddressSubscriptionWaiter extends Waiter {
  Set<Address> backlog = {};

  void init() {
    //  setupSubscriptionsListener();
    setupClientListener();
  }

  //void setupSubscriptionsListener() => listen(
  //      'movementDetected',
  //      services.client.subscribe.movementDetected,
  //      (Address address) {
  //        unawaited(retrieve(address));
  //      },
  //    );

  void deinitSubscriptionHandles() {
    for (var listener in services.client.subscribe.subscriptionHandles.values) {
      listener.cancel();
    }
    services.client.subscribe.subscriptionHandles.clear();
  }

  void setupClientListener() => listen(
        'streams.client.connected',
        streams.client.connected,
        (bool connected) async {
          if (connected) {
            await retrieveAllBacklog();
          } else {
            deinitSubscriptionHandles();
          }
        },
      );

  Future retrieve(Address address) async {
    var msg = 'Downloading transactions for ${address.address}';
    services.busy.clientOn(msg);
    if (await services.address.getAndSaveTransactionsByAddresses(address)) {
      backlog.remove(address);
    } else {
      backlog.add(address);
    }
    services.busy.clientOff(msg);
  }

  Future retrieveAllBacklog() async {
    var msg = 'Downloading transactions...';
    services.busy.clientOn(msg);
    var returnToBacklog = <Address>{};
    for (var address in backlog) {
      if (!await services.address.getAndSaveTransactionsByAddresses(address)) {
        returnToBacklog.add(address);
      }
    }
    backlog = returnToBacklog;
    services.busy.clientOff(msg);
  }
}
