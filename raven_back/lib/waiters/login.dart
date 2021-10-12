import 'package:raven/raven.dart';
import 'waiter.dart';

class LoginWaiter extends Waiter {
  void init() {
    listen('subjects.login', subjects.login, (login) {
      /* what should I do when I hear we logged in or logged out?*/
    });
  }
}
