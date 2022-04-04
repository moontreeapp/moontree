import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class SubscriptionWaiter extends Waiter {
  void init() {
    listen('streams.client.connected', streams.client.connected,
        (bool connected) {
      print('CLIENT CONNECTED $connected');
      connected
          ? services.client.subscribe.toAllAddresses()
          : deinitAllSubscriptions();
    });
    //(bool connected) => connected
    //    ? services.client.subscribe.toAllAddresses()
    //    : deinitAllSubscriptions());
  }

  void deinitAllSubscriptions() {
    for (var listener in services.client.subscribe.subscriptionHandles.values) {
      listener.cancel();
    }
    services.client.subscribe.subscriptionHandles.clear();
    services.history.downloaded.clear();
  }
}
