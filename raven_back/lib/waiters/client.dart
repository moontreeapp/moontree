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
    listeners.add(ravenClientSubject.stream.listen((ravenClient) {
      if (ravenClient != null) {
        print('client connected!!!');
        mostRecentRavenClient = ravenClient;
        ravenClient.peer.done
            .then((value) => ravenClientSubject.sink.add(null));
      } else {
        print('not connected $retriesLeft, ${services.client.chosenDomain}');
        mostRecentRavenClient?.close();
        periodicTimer =
            Stream.periodic(connectionTimeout + Duration(seconds: 1))
                .listen((_) async {
          print('periodic');
          ravenClient = await services.client.createClient();
          print(ravenClient);
          if (ravenClient != null) {
            print('periodic - null');
            ravenClientSubject.sink.add(ravenClient);
            await periodicTimer?.cancel();
          } else {
            print('periodic - else - $retriesLeft');
            retriesLeft =
                retriesLeft <= 0 ? retries : retriesLeft = retriesLeft - 1;
            services.client.cycleNextElectrumConnectionOption();
          }
        });
      }
    }));
    ravenClientSubject.sink.add(null); // seems to have no effect
  }
}
