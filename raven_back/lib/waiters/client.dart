import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const int retries = 3;

  StreamSubscription? periodicTimer;
  int retriesLeft = retries;

  void init() {
    // TODO: is this conditional necessary
    if (!listeners.keys.contains('subjects.client')) {
      subjects.client.sink.add(null);
    }

    listen('subjects.client', subjects.client, (ravenClient) async {
      if (ravenClient != null) {
        await periodicTimer?.cancel();
        services.client.mostRecentRavenClient =
            ravenClient as RavenElectrumClient;

        // maybe we need another way to determine if it's closed.
        //ravenClient.peer.listen(closed... )
        // ignore: unawaited_futures
        ravenClient.peer.done.then((value) async {
          //print('DONE!!!');
          //print(value);
          ////var mostRecent = await subjects.client.stream.last; // awaits forever
          ////print(mostRecent);
          ////if (mostRecent != null) {
          ////  // shouldn't this just always happen? why do we check most recent?
          ////  print('ADDING NONE TO SINK');
          subjects.client.sink.add(null);
          ////}
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
  }
}
