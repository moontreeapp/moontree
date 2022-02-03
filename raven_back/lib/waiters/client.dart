import 'dart:async';

import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 5);
  Duration additionalTimeout = Duration(seconds: 1);

  StreamSubscription? periodicTimer;

  void init({Object? reconnect}) {
    if (!listeners.keys.contains('streams.client.client')) {
      streams.client.client.add(null);
    }

    listen(
      'streams.client.client',
      streams.client.client,
      (RavenElectrumClient? client) async {
        if (client != null) {
          await periodicTimer?.cancel();
          unawaited(client.peer.done.then((value) async {
            streams.client.connected.add(false);
            if (streams.app.active.value) {
              streams.client.client.add(null);
            }
          }));
        } else {
          streams.client.connected.add(false);
          await streams.client.client.value?.close();
          await periodicTimer?.cancel();
          periodicTimer =
              Stream.periodic(connectionTimeout + additionalTimeout).listen(
            (_) async {
              if (streams.app.active.value) {
                var newRavenClient = await services.client.createClient();
                if (newRavenClient != null) {
                  streams.client.connected.add(true);
                  streams.client.client.add(newRavenClient);
                  await periodicTimer?.cancel();
                } else {
                  additionalTimeout += connectionTimeout;
                }
              }
            },
          );
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
        /*var msg = 'Establishing Connection...';*/
        if (active && (streams.client.client.value == null || !connected)) {
          additionalTimeout = Duration(seconds: 1);
          streams.client.client.add(null);
          /*services.busy.clientOn();
        } else if (active) {
          services.busy.clientOff();*/
        }
      },
    );

    listen(
        'settings.changes',
        res.settings.changes.where((change) =>
            (change is Added || change is Updated) &&
            change.data.name == SettingName.Electrum_Net), (_) {
      streams.client.client.add(null);
    });
  }
}
