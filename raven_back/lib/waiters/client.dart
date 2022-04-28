import 'dart:async';

import 'package:raven_back/streams/client.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 6);
  static const Duration originalAdditionalTimeout = Duration(seconds: 1);
  Duration additionalTimeout = originalAdditionalTimeout;

  StreamSubscription? periodicTimer;

  //late clientDoneListener =

  void init({Object? reconnect}) {
    if (!listeners.keys.contains('streams.client.client')) {
      streams.client.client.add(null);
    }

    /// maintains an active connection to electrum server as long app is active
    ///
    listen(
      'streams.client.client',
      streams.client.client,
      (RavenElectrumClient? client) async {
        if (client != null) {
          await periodicTimer?.cancel();

          /// this isn't getting executed when the server closes the connection.
          /// we've setup a ping to help us avoid the server closing our
          /// connection, but if it does happen we wont know about it until we
          /// try to use the client connection object again. then it will error.
          /// but we do have, as an alternative to this, a client scope function
          /// which allows us to automatically reconnect if we're not connected.
          unawaited(client.peer.done.then((value) async {
            streams.client.connected.add(ConnectionStatus.disconnected);
            if (streams.app.active.value) {
              streams.client.client.add(null);
            }
          }, onError: (value) async {
            print('Client ERROR $value');
            streams.client.connected.add(ConnectionStatus.disconnected);
            if (streams.app.active.value) {
              streams.client.client.add(null);
            }
          }));
        } else {
          streams.client.connected.add(ConnectionStatus.connecting);
          await streams.client.client.value?.close();
          await periodicTimer?.cancel();
          periodicTimer = Stream.periodic(connectionTimeout).listen(
            (_) async {
              if (streams.app.active.value) {
                var newRavenClient = await services.client.createClient();
                if (newRavenClient != null) {
                  streams.client.connected.add(ConnectionStatus.connected);
                  streams.client.client.add(newRavenClient);
                  await periodicTimer?.cancel();
                  additionalTimeout = originalAdditionalTimeout;
                } else {
                  additionalTimeout += originalAdditionalTimeout;
                  //periodicTimer!.pause();
                  //await Future.delayed(additionalTimeout);
                  //periodicTimer!.resume();
                  while (!streams.app.active.value) {
                    print(
                        'streams.app.active.value: ${streams.app.active.value}');
                    await Future.delayed(Duration(seconds: 1));
                  }
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
        (ConnectionStatus connected, bool active) => Tuple2(connected, active),
      ),
      (Tuple2 tuple) async {
        ConnectionStatus connected = tuple.item1;
        bool active = tuple.item2;
        /*var msg = 'Establishing Connection...';*/
        if (active &&
            (streams.client.client.value == null &&
                connected == ConnectionStatus.disconnected)) {
          additionalTimeout = Duration(seconds: 1);
          streams.client.client.add(null);
          await Future.delayed(Duration(seconds: 6));
        } else if (active) {}
      },
    );

    listen(
        'settings.changes',
        res.settings.changes.where((change) =>
            (change is Added || change is Updated) &&
            change.data.name == SettingName.Electrum_Net), (_) {
      streams.client.client.add(null);
    });

    /// this pings the server every 60 seconds if the user is using the app and
    /// we have a connection to the server. it's good enough. what would be
    /// better is to make a clock that resets to 0 every time we send any
    /// request to the server, if the clock hits 60 seconds it sends a ping.
    listen(
      'streams.app.ping',
      CombineLatestStream.combine3(
        streams.client.client,
        streams.app.active,
        streams.app.ping,
        (RavenElectrumClient? client, bool active, dynamic ping) =>
            Tuple3(client, active, ping),
      ).where((Tuple3 event) => event.item1 != null && event.item2),
      (Tuple3 tuple) {
        //RavenElectrumClient? client = tuple.item1;
        /// I think this is getting called when the app becomes active again without a working client
        services.client.scope(services.client.client!.ping);
        //try {
        //  client!.ping();
        //} on StateError {
        //  print(
        //      'STATE ERROR - server must have closed our connection without us knowing.');
        //  streams.client.client.add(null);
        //}
      },
    );
  }
}
