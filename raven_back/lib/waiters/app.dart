import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'waiter.dart';

class AppWaiter extends Waiter {
  DateTime lastActiveTime = DateTime.now();
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
    /// most of this is superceded by logoutThread which gets called on init and never ends.
    /// I discovered more about why this is a bad solution, though suprisingly the popular one:
    /// you only get notifications about the tap, you know know the user was active,
    /// if the user clicks on something that doesn't capture the gesture. if you click on a
    /// button or something, then the button gets the gesture, not this, so you have no
    /// way of knowing if it's really been active.
    /// One thing we could do is track navigation events, everytime you move pages - we
    /// could use that as a proxy for activity perhaps. maybe a combination of both...
    /// I'll leave this all in here for now.
    listen(
      'streams.app.tap',
      streams.app.tap,
      (bool? value) async {
        lastActiveTime = DateTime.now();
        //if (services.password.required) {
        //  print('starting');
        //  await Future.delayed(Duration(seconds: gracePeriod));
        //  print('streams.app.logout.value${streams.app.logout.value}');
        //  if (!streams.app.logout.value &&
        //      DateTime.now().difference(lastActiveTime).inSeconds >=
        //          gracePeriod) {
        //    streams.app.logout.add(true);
        //  }
        //}
      },
    );
    //
    //listen(
    //  'streams.app.logout',
    //  streams.app.logout,
    //  (bool? value) async {
    //    if (value != null && !value) {
    //      lastLoginTime = DateTime.now();
    //      Timer(Duration(seconds: gracePeriod), () {
    //        //timer cancel fails so at least don't lock if we're back in it.
    //        if (!streams.app.logout.value &&
    //            DateTime.now().difference(lastActiveTime).inSeconds >=
    //                gracePeriod) {
    //          streams.app.logout.add(true);
    //        }
    //      });
    //    }
    //  },
    //);
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
