import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
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
    /* seeing multiple connections on the server - either due to this or 
     * services.client.scope calls. attempting to make one or the other work
     * rather than both at the same time
    
    if (!listeners.keys.contains('streams.client.client')) {
      streams.client.client.add(null);
    }

    
    

    /// maintains an active connection to electrum server as long app is active
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



    /// creation of client should happen in one place, either here or in scope.
    listen(
      'streams.client.client',
      streams.client.client,
      (RavenElectrumClient? client) async {
        if (client == null) {
          streams.client.connected.add(ConnectionStatus.connecting);
          var newRavenClient = await services.client.createClient();
          if (newRavenClient != null) {
            streams.client.connected.add(ConnectionStatus.connected);
            streams.client.client.add(newRavenClient);
          }
        }
      },
    );
    */

    /// when we become active and we don't have a connection, reconnect.
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        if (active) {
          print(
              'CONNECTION STATUS: ${streams.client.connected.value.enumString} ACTIVE $active');
          print('PINGING ELECTRUM SERVER');
          await services.client.api.ping();
          print(
              'CONNECTION STATUS: ${streams.client.connected.value.enumString}');
        }
      },
    );

    /// this pings the server every 60 seconds if the user is using the app and
    /// we have a connection to the server. it's good enough. what would be
    /// better is to make a clock that resets to 0 every time we send any
    /// request to the server, if the clock hits 60 seconds it sends a ping.
    listen(
      'streams.app.ping',
      CombineLatestStream.combine2(
        streams.app.active,
        streams.app.ping,
        (bool active, dynamic ping) => Tuple2(active, ping),
      ).where((Tuple2 event) => event.item1),
      (Tuple2 tuple) async {
        //RavenElectrumClient? client = tuple.item1;
        /// I think this is getting called when the app becomes active again without a working client
        print(
            'CONNECTION STATUS: ${streams.client.connected.value.enumString} ACTIVE ${tuple.item1}, ping ${tuple.item2}');
        print('PINGING ELECTRUM SERVER');
        await services.client.api.ping();
        print(
            'CONNECTION STATUS: ${streams.client.connected.value.enumString}');
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
