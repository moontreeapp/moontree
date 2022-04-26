import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  int gracePeriod = 60 * 2;
  Timer? _timer;

  void init({Object? reconnect}) {
    /// when app has been inactive for 2 minutes logout
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) {
        if (active) {
          //print('');
          //print('why not canceling');
          //print('');
          _timer?.cancel();
          _timer = null;
        } else if (!active && services.password.required) {
          _timer = Timer(
            Duration(seconds: gracePeriod),
            () {
              //timer cancel fails so at least don't lock if we're back in it.
              if (!streams.app.active.value) {
                streams.app.logout.add(true);
              }
            },
          );
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
