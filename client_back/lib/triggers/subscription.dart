import 'dart:async';

import 'package:client_back/client_back.dart';
import 'package:client_back/streams/client.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class SubscriptionWaiter extends Trigger {
  void init() {
    when(
      thereIsA: streams.client.connected.where((ConnectionStatus connected) =>
          connected == ConnectionStatus.connected),
      doThis: (ConnectionStatus connected) => pros.addresses.isNotEmpty
          ? services.client.subscribe.toAllAddresses()
          : deinitAllSubscriptions(),
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
