import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';
import 'package:raven/waiters.dart';

class ExchangeRateService extends Service {
  late StreamSubscription<List<Change>> listener;

  ExchangeRateService() : super();

  @override
  Future init() async {
    // on open
    var waiter = RatesWaiter();
    await waiter.saveRate();

    /// setup listener to get the conversion rate on manual refresh
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
