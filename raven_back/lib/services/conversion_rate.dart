import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/conversion.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/rate.dart';

class ConversionRateService extends Service {
  ConversionRateReservoir conversions;

  late StreamSubscription<List<Change>> listener;

  ConversionRateService(this.conversions) : super();

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
    conversions.save(await conversionRate('usd'));
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
