import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/rate.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/rate.dart';

class ConversionRateService extends Service {
  ConversionRateReservoir rates;

  late StreamSubscription<List<Change>> listener;

  ConversionRateService(this.rates) : super();

  @override
  Future init() async {
    /// get the conversion rate...
    // on open
    // on manual refresh
    //listener = conversions.changes.listen(saveRate);
    await saveRate();
  }

  // runs it for affected account-ticker combinations
  Future saveRate() async {
    rates.save(await conversionRate('usd'));
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
