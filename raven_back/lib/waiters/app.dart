import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  DateTime lastInactiveTime = DateTime.now();
  int gracePeriod = 60 * 2;

  void init({Object? reconnect}) {
    /// when app has been inactive for 2 minutes logout
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        if (!active && services.password.required) {
          lastInactiveTime = DateTime.now();
          await Future.delayed(Duration(seconds: gracePeriod));
          if (streams.app.active.value &&
              DateTime.now().difference(lastInactiveTime).inSeconds >=
                  gracePeriod) {
            //streams.app.locked.add(true);
            /// just logout
            streams.app.logout.add(true);
          }
        }
      },
    );

    /// when app isn't used for 2 minutes lock
    // we don't have a listener for user behavior yet...
  }
}
