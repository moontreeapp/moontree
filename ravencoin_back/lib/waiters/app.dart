import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

class AppWaiter extends Waiter {
  DateTime lastActiveTime = DateTime.now();
  int inactiveGracePeriod = 30;
  int idleGracePeriod = 60 * 5;
  Timer? _inactiveTimer;

  void init({Object? reconnect}) {
    /// logout on minimize
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        if (!active &&
            services.password.required &&
            streams.app.authenticating.value == false &&
            streams.app.browsing.value == false) {
          /// you can remove the timer stuff for immediate logout
          //streams.app.logout.add(true);
          _inactiveTimer = Timer(
            Duration(seconds: inactiveGracePeriod),
            () {
              if (!streams.app.active.value) {
                streams.app.logout.add(true);
                _inactiveTimer?.cancel();
                _inactiveTimer = null;
              }
            },
          );
        } else if (active) {
          streams.app.browsing.add(false);
          _inactiveTimer?.cancel();
          _inactiveTimer = null;
        }
      },
    );

    /// when app isn't used for 5 minutes lock
    /// we know the user is active by navigation events and gestures that aren't
    /// captured by a button or anything
    listen(
      'streams.app.tap',
      streams.app.tap,
      (bool? value) async => lastActiveTime = DateTime.now(),
    );
  }

  /// only active when the app is active
  Future<void> logoutThread() async {
    while (true) {
      var x = DateTime.now().difference(lastActiveTime).inSeconds;
      await Future<void>.delayed(
          Duration(seconds: idleGracePeriod - (idleGracePeriod > x ? x : 0)));
      if (
          // we have a password
          services.password.required &&
              // are we logged in?
              !streams.app.logout.value &&
              // have we had no activity while we've been waiting?
              DateTime.now().difference(lastActiveTime).inSeconds >=
                  idleGracePeriod) {
        streams.app.logout.add(true);
      }
    }
  }
}
