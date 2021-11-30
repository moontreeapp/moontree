import 'dart:async';

import 'package:raven_back/raven_back.dart';

import 'waiter.dart';

class RateWaiter extends Waiter {
  static const Duration rateWait = Duration(minutes: 10);

  Future init() async {
    unawaited(services.rate.saveRate());

    listen(
      'periodic',
      Stream.periodic(rateWait),
      (_) {
        services.rate.saveRate();
      },
    );
  }
}
