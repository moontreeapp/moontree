import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

class SubscriptionWaiter extends Waiter {
  void init() {
    listen(
      'streams.client.connected',
      streams.client.connected,
      (ConnectionStatus connected) {
        pros.addresses.isNotEmpty
            ? connected == ConnectionStatus.connected
                ? services.client.subscribe.toAllAddresses()
                : deinitAllSubscriptions()
            : () {};
      },
    );
  }

  void deinitAllSubscriptions() {
    for (final Map<String, StreamSubscription<dynamic>> addressMap
        in services.client.subscribe.subscriptionHandlesAddress.values) {
      for (final StreamSubscription<dynamic> listener in addressMap.values) {
        listener.cancel();
      }
    }
    for (final StreamSubscription<dynamic> listener
        in services.client.subscribe.subscriptionHandlesAsset.values) {
      listener.cancel();
    }
    services.client.subscribe.subscriptionHandlesAddress.clear();
    services.client.subscribe.subscriptionHandlesAsset.clear();

    //services.download.history.clearDownloadState();
    //await pros.unspents.clear(); ?
  }
}
