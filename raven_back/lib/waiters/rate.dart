import 'dart:async';

import 'package:raven/raven.dart';

import 'waiter.dart';

class RateWaiter extends Waiter {
  Future init() async {
    // on open
    await services.rate.saveRate();

    /// setup listener to get the conversion rate on manual refresh
  }
}
