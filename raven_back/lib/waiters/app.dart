import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  int gracePeriod = 6; //0 * 2;
  Timer? _timer;

  void init({Object? reconnect}) {
    /// when app has been inactive for 2 minutes logout
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) async {
        if (active) {
          if (_timer != null) {
            _timer!.cancel();
          }
        }

        if (!active && services.password.required) {
          _timer = Timer(Duration(seconds: gracePeriod), () {
            if (streams.app.active.value) {
              streams.app.logout.add(true);
            }
          });
        }
      },
    );

    /// when app isn't used for 2 minutes lock
    // we don't have a listener for user behavior yet...
    /// I was hoping we could use a GuestureBinding or something
    /// (see status.dart) but I'm seeing people suggest wraping the entire app
    /// in a transparent GuestureDetector... maybe...
    /// https://stackoverflow.com/questions/58956814/how-to-execute-a-function-after-a-period-of-inactivity-in-flutter
  }
}
