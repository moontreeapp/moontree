import 'dart:async';

import 'package:raven/waiters/waiter.dart';
import 'package:raven/services.dart';

class ExchangeRateWaiter extends Waiter {
  RatesService ratesService;
  ExchangeRateWaiter(this.ratesService) : super();

  @override
  Future init() async {
    // on open
    await ratesService.saveRate();

    /// setup listener to get the conversion rate on manual refresh
  }
}
