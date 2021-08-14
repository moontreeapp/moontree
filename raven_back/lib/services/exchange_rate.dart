import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';
import 'package:raven/waiters.dart';

class ExchangeRateService extends Service {
  RatesWaiter ratesWaiter;
  late StreamSubscription<List<Change>> listener;

  ExchangeRateService(this.ratesWaiter) : super();

  @override
  Future init() async {
    // on open
    await ratesWaiter.saveRate();

    /// setup listener to get the conversion rate on manual refresh
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
