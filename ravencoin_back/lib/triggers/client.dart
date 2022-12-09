import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;
import 'package:electrum_adapter/methods/server/ping.dart';

class RavenClientWaiter extends Trigger {
  static const Duration connectionTimeout = Duration(seconds: 6);
  static const Duration originalAdditionalTimeout = Duration(seconds: 1);
  Duration additionalTimeout = originalAdditionalTimeout;

  //StreamSubscription<dynamic>? periodicTimer;

  int pinged = 0;

  void init({Object? reconnect}) {
    /// this pings the server every 60 seconds if the user is using the app and
    /// we have a connection to the server. it's good enough. what would be
    /// better is to make a clock that resets to 0 every time we send any
    /// request to the server, if the clock hits 60 seconds it sends a ping.
    when(
      thereIsA: CombineLatestStream.combine2(
        streams.app.active,
        streams.app.ping,
        (bool active, dynamic ping) => active,
      ).where((bool active) => active),
      doThis: performPing,
    );
  }

  Future<void> performPing(bool _) async {
    try {
      // todo: when this reconnects sometimes it doubles up and makes two
      // connections. could it be the timeout on some client call is long
      // enough that it overlaps two pings? well pinging half as often should
      // fix it if that's the case. set it for 60*2 and will watch out for it.
      await (await services.client.client).ping();
      pinged++;
    } catch (e) {
      print('unable to ping...');
      await services.client.createClient();
      pinged = 0;
    }
  }
}
