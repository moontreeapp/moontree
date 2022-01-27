import 'dart:async';
import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class SubscriptionWaiter extends Waiter {
  Set<Address> backlog = {};

  void init() {
    setupClientListener();
  }

  void deinitSubscriptionHandles() {
    for (var listener in services.client.subscribe.subscriptionHandles.values) {
      listener.cancel();
    }
    services.client.subscribe.subscriptionHandles.clear();
  }

  void setupClientListener() => listen(
      'streams.client.connected',
      streams.client.connected,
      (bool connected) async =>
          connected ? await retrieveAllBacklog() : deinitSubscriptionHandles());

  Future retrieve(Address address) async =>
      await services.history.getHistories(address)
          ? backlog.remove(address)
          : backlog.add(address);

  Future retrieveAllBacklog() async {
    var returnToBacklog = <Address>{};
    for (var address in backlog) {
      if (!await services.history.getHistories(address)) {
        returnToBacklog.add(address);
      }
    }
    backlog = returnToBacklog;
  }
}
