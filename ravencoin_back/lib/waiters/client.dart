import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'waiter.dart';
import 'package:electrum_adapter/methods/server/ping.dart';

class RavenClientWaiter extends Waiter {
  static const Duration connectionTimeout = Duration(seconds: 6);
  static const Duration originalAdditionalTimeout = Duration(seconds: 1);
  Duration additionalTimeout = originalAdditionalTimeout;

  StreamSubscription? periodicTimer;

  int pinged = 0;

  void init({Object? reconnect}) {
    /// this pings the server every 60 seconds if the user is using the app and
    /// we have a connection to the server. it's good enough. what would be
    /// better is to make a clock that resets to 0 every time we send any
    /// request to the server, if the clock hits 60 seconds it sends a ping.
    listen(
      'streams.app.ping',
      CombineLatestStream.combine2(
        streams.app.active,
        streams.app.ping,
        (bool active, dynamic ping) => active,
      ).where((active) => active),
      performPing,
    );
  }

  Future<void> performPing(bool active) async {
    if (active) {
      try {
        await (await services.client.client).ping();
        pinged++;
      } catch (e) {
        print('unable to ping...');
        await services.client.createClient();
        pinged = 0;
      }
    }
  }
}
