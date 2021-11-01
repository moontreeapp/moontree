import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const int retries = 3;

  StreamSubscription? periodicTimer;
  int retriesLeft = retries;

  bool clientConnected = false;
  bool appActive = true;

  void init({Object? reconnect}) {
    if (!listeners.keys.contains('subjects.client')) {
      subjects.client.sink.add(null);
    }
    if (!listeners.keys.contains('subjects.app')) {
      subjects.app.sink.add(null);
    }

    listen('subjects.client', subjects.client, (ravenClient) async {
      if (ravenClient != null) {
        await periodicTimer?.cancel();
        services.client.mostRecentRavenClient =
            ravenClient as RavenElectrumClient;
        clientConnected = true;
        // ignore: unawaited_futures
        ravenClient.peer.done.then((value) async {
          /// if the state of the app is not in the foreground (being used)
          /// we shouldn't yet reconnect, that just wastes resources as we
          /// need to set up all the subscriptions again on the new instance.
          /// client will be activated again by other app status listener.
          clientConnected = false;
          if (appActive) {
            subjects.client.sink.add(null);
          }
        });
      } else {
        await services.client.mostRecentRavenClient?.close();
        await periodicTimer?.cancel();
        periodicTimer =
            Stream.periodic(connectionTimeout + Duration(seconds: 1))
                .listen((_) async {
          var newRavenClient = await services.client.createClient();
          if (newRavenClient != null) {
            subjects.client.sink.add(newRavenClient);
            await periodicTimer?.cancel();
          } else {
            retriesLeft =
                retriesLeft <= 0 ? retries : retriesLeft = retriesLeft - 1;
            services.client.cycleNextElectrumConnectionOption();
          }
        });
      }
    });

    /// save latest app status, .
    listen('subjects.app', subjects.app, (appStatus) {
      if (appStatus == 'resumed') {
        appActive = true;
        if (services.client.mostRecentRavenClient == null || !clientConnected) {
          subjects.client.sink.add(null);
        }
      } else {
        appActive = false;
      }
    });
  }
}
