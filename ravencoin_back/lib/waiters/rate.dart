import 'dart:async';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/rate.dart';
import 'package:ravencoin_back/waiters/waiter.dart';

class RateWaiter extends Waiter {
  // should be pushed to clients on change instead
  static const Duration _rateWait = Duration(minutes: 10);

  void init(RVNRateInterface rvnRate) {
    _saveRate(rvnRate);
    listen(
      'periodic',
      Stream<dynamic>.periodic(_rateWait),
      (_) async => _save(await _rate(rvnRate)),
    );
  }

  Future<double> _rate(RVNRateInterface rvnRate) async =>
      await rvnRate.get() ??
      pros.rates.primaryIndex
          .getOne(pros.securities.RVN, pros.securities.USD)
          ?.rate ??
      0.0; // instead of hardcoding a default we might disable the feature to see anything in USD on the front end...

  Future<Change<Rate>?> _save(double rate) async => pros.rates.save(Rate(
        base: pros.securities.RVN,
        quote: pros.securities.USD,
        rate: rate,
      ));

  Future<Change<Rate>?> _saveRate(RVNRateInterface rvnRate) async =>
      _save(await _rate(rvnRate));
}
