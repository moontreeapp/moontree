import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  DateTime lastActiveTime = DateTime.now();
  int gracePeriod = 60 * 5;
  Timer? _timer;

  void init({Object? reconnect}) {
    /// when app has been inactive for 2 minutes logout
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        if (active) {
          _timer?.cancel();
          _timer = null;
        } else if (!active && services.password.required) {
          _timer = Timer(
            Duration(seconds: gracePeriod),
            () {
              if (!streams.app.active.value) {
                streams.app.logout.add(true);
              }
            },
          );
        }
      },
    );

    /// when app isn't used for 2 minutes lock
    /// we know the user is active by navigation events and gestures that aren't
    /// captured by a button or anything
    listen(
      'streams.app.tap',
      streams.app.tap,
      (bool? value) async {
        lastActiveTime = DateTime.now();
      },
    );
  }

  Future<void> logoutThread() async {
    while (true) {
      var x = DateTime.now().difference(lastActiveTime).inSeconds;
      await Future.delayed(
          Duration(seconds: gracePeriod - (gracePeriod > x ? x : 0)));
      if (
          // we have a password
          services.password.required &&
              // are we logged in?
              !streams.app.logout.value &&
              // have we had no activity while we've been waiting?
              DateTime.now().difference(lastActiveTime).inSeconds >=
                  gracePeriod) {
        streams.app.logout.add(true);
      }
    }
  }
}
