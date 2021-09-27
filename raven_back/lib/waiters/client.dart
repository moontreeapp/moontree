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
    listeners.add(subjects.client.stream.listen((ravenClient) {
      if (ravenClient != null) {
        mostRecentRavenClient = ravenClient;
        ravenClient.peer.done.then((value) => subjects.client.sink.add(null));
      } else {
        mostRecentRavenClient?.close();
        periodicTimer =
            Stream.periodic(connectionTimeout + Duration(seconds: 1))
                .listen((_) async {
          ravenClient = await services.client.createClient();
          if (ravenClient != null) {
            subjects.client.sink.add(ravenClient);
            await periodicTimer?.cancel();
          } else {
            retriesLeft =
                retriesLeft <= 0 ? retries : retriesLeft = retriesLeft - 1;
            services.client.cycleNextElectrumConnectionOption();
          }
        });
      }
    }));
    subjects.client.sink.add(null);
  }
}
