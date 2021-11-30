import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const int retries = 3;

  StreamSubscription? periodicTimer;
  int retriesLeft = retries;

  void init({Object? reconnect}) {
    if (!listeners.keys.contains('streams.client.client')) {
      streams.client.client.sink.add(null);
    }

    listen(
      'streams.client.client',
      streams.client.client,
      (RavenElectrumClient? client) async {
        if (client != null) {
          await periodicTimer?.cancel();
          unawaited(client.peer.done.then((value) async {
            streams.client.connected.sink.add(false);
            if (streams.app.active.value) {
              streams.client.client.sink.add(null);
            }
          }));
        } else {
          await streams.client.client.value?.close();
          await periodicTimer?.cancel();
          periodicTimer =
              Stream.periodic(connectionTimeout + Duration(seconds: 1))
                  .listen((_) async {
            if (streams.app.active.value) {
              var newRavenClient = await services.client.createClient();
              if (newRavenClient != null) {
                streams.client.connected.sink.add(true);
                streams.client.client.sink.add(newRavenClient);
                await periodicTimer?.cancel();
              } else {
                retriesLeft =
                    retriesLeft <= 0 ? retries : retriesLeft = retriesLeft - 1;
                services.client.cycleNextElectrumConnectionOption();
              }
            }
          });
        }
      },
    );

    /// when we become active and we don't have a connection, reconnect.
    listen(
      'streams.app.active',
      CombineLatestStream.combine2(
        streams.client.connected,
        streams.app.active,
        (bool connected, bool active) => Tuple2(connected, active),
      ),
      (Tuple2 tuple) {
        bool active = tuple.item1;
        bool connected = tuple.item2;
        if (active && (streams.client.client.value == null || !connected)) {
          streams.client.client.sink.add(null);
        }
      },
    );
  }
}
