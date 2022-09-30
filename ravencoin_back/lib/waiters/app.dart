import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  DateTime lastActiveTime = DateTime.now();
  int gracePeriod = 6 * 5;

  /// we used to lock according to this timer
  /// but now we lock whenever we minimize the app.
  //Timer? _inactiveTimer;

  void init({Object? reconnect}) {
    /// when app has been inactive for 5 minutes logout
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        print('activity gets inited');
        if (active) {
          print('ACTIVE');
          //_inactiveTimer?.cancel();
          //_inactiveTimer = null;
        } else if (!active && services.password.required) {
          print('INACTIVE');
          streams.app.logout.add(true);
          //_inactiveTimer = Timer(
          //  Duration(seconds: gracePeriod),
          //  () {
          //    print('LOGGING OUT BECAUSE OF _inactiveTimer');
          //    if (!streams.app.active.value) {
          //      streams.app.logout.add(true);
          //    }
          //  },
          //);
        }
      },
    );

    /// when app isn't used for 5 minutes lock
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

  /// used for when the app is active, _inactiveTimer is used when app inactive.
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
        print('LOGGING OUT BECAUSE OF logoutThread');
        streams.app.logout.add(true);
      }
    }
  }
}
