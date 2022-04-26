import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  void init({Object? reconnect}) {
    /// when app becomes inactive lock
    listen(
      'streams.app.active',
      streams.app.active,
      (bool active) {
        if (!active && services.password.required) {
          streams.app.locked.add(true);
        }
      },
    );

    /// when app isn't used for 2 minutes lock
    // we don't have a listener for user behavior yet...
  }
}
