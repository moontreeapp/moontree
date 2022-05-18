import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'waiter.dart';

class SubscriptionWaiter extends Waiter {
  void init() {
    listen(
      'streams.client.connected',
      streams.client.connected,
      (ConnectionStatus connected) {
        res.addresses.isNotEmpty
            ? connected == ConnectionStatus.connected
                ? services.client.subscribe.toAllAddresses()
                : deinitAllSubscriptions()
            : () {};
      },
    );
  }

  void deinitAllSubscriptions() {
    for (var listener
        in services.client.subscribe.subscriptionHandlesAddress.values) {
      listener.cancel();
    }
    for (var listener
        in services.client.subscribe.subscriptionHandlesAsset.values) {
      listener.cancel();
    }
    services.client.subscribe.subscriptionHandlesAddress.clear();
    services.client.subscribe.subscriptionHandlesAsset.clear();

    //services.download.history.clearDownloadState();
    //await res.unspents.clear(); ?
  }
}
