import 'dart:async';

import 'package:raven/raven.dart';

import 'waiter.dart';

class RateWaiter extends Waiter {
  static const Duration rateWait = Duration(minutes: 10);

  Future init() async {
    listen(
      'periodic',
      Stream.periodic(rateWait),
      (_) {
        services.rate.saveRate();
      },
    );
  }
}
