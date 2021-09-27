import 'package:raven/raven.dart';
import 'waiter.dart';

class LoginWaiter extends Waiter {
  void init() {
    if (!listeners.keys.contains('subjects.login')) {
      listeners['subjects.login'] = subjects.login.stream.listen((login) {
        /* what should I do when I hear we logged in or logged out?*/
      });
    }
  }
}
