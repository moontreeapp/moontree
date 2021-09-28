import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const int retries = 3;

  RavenElectrumClient? mostRecentRavenClient;
  StreamSubscription? periodicTimer;
  int retriesLeft = retries;

  void init() {
    if (!listeners.keys.contains('subjects.client')) {
      listeners['subjects.client'] =
          subjects.client.stream.listen((ravenClient) async {
        if (ravenClient != null) {
          await periodicTimer?.cancel();
          mostRecentRavenClient = ravenClient;
          // ignore: unawaited_futures
          ravenClient.peer.done.then((value) async {
            var mostRecent = await subjects.client.stream.last;
            if (mostRecent != null) {
              subjects.client.sink.add(null);
            }
          });
        } else {
          await mostRecentRavenClient?.close();
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
      subjects.client.sink.add(null);
    }
  }
}
