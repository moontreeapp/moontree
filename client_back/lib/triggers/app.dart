import 'dart:async';
import 'package:client_back/client_back.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class AppWaiter extends Trigger {
  DateTime lastActiveTime = DateTime.now();
  int inactiveGracePeriod = 30;
  int idleGracePeriod = 60 * 5;
  Timer? _inactiveTimer;

  void init({Object? reconnect}) {
    /// logout on minimize
    when(
      thereIsA: streams.app.active.active,
      doThis: (bool active) async {
        if (!active &&
            services.password.required &&
            streams.app.auth.authenticating.value == false &&
            streams.app.loc.browsing.value == false) {
          /// you can remove the timer stuff for immediate logout
          //streams.app.auth.logout.add(true);
          _inactiveTimer = Timer(
            Duration(seconds: inactiveGracePeriod),
            () {
              if (!streams.app.active.active.value) {
                streams.app.auth.logout.add(true);
                _inactiveTimer?.cancel();
                _inactiveTimer = null;
              }
            },
          );
        } else if (active) {
          streams.app.loc.browsing.add(false);
          _inactiveTimer?.cancel();
          _inactiveTimer = null;
        }
      },
    );

    /// when app isn't used for 5 minutes lock
    /// we know the user is active by navigation events and gestures that aren't
    /// captured by a button or anything
    when(
      thereIsA: streams.app.active.tap,
      doThis: (bool? _) async => lastActiveTime = DateTime.now(),
    );
  }

  /// only active when the app is active
  Future<void> logoutThread() async {
    while (true) {
      final int x = DateTime.now().difference(lastActiveTime).inSeconds;
      await Future<void>.delayed(
          Duration(seconds: idleGracePeriod - (idleGracePeriod > x ? x : 0)));
      if (
          // we have a password
          services.password.required &&
              // are we logged in?
              !streams.app.auth.logout.value &&
              // have we had no activity while we've been waiting?
              DateTime.now().difference(lastActiveTime).inSeconds >=
                  idleGracePeriod) {
        streams.app.auth.logout.add(true);
      }
    }
  }
}
