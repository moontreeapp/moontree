import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const int retries = 3;

  RavenElectrumClient? lastRavenClient;
  StreamSubscription? periodicTimer;
  int retriesLeft = retries;

  void init() {
    listeners.add(ravenClientSubject.stream.listen((ravenClient) {
      if (ravenClient != null) {
        periodicTimer?.cancel();
        lastRavenClient = ravenClient;
        ravenClient.peer.done
            .then((value) => ravenClientSubject.sink.add(null));
      } else {
        lastRavenClient?.close();
        periodicTimer = Stream.periodic(connectionTimeout).listen((_) async {
          ravenClient = await services.client.createClient();
          if (ravenClient != null) {
            ravenClientSubject.sink.add(ravenClient);
          } else {
            if (retriesLeft > 0) {
              retriesLeft = retriesLeft - 1;
            } else {
              retriesLeft = retries;
              services.client.cycleNextElectrumConnectionOption();
            }
          }
        });
      }
    }));
  }
}
