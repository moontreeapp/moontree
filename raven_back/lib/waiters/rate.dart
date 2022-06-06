import 'dart:async';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/utilities/rate.dart';
import 'waiter.dart';

class RateWaiter extends Waiter {
  // should be pushed to clients on change instead
  static const Duration _rateWait = Duration(minutes: 10);

  void init(RVNRateInterface rvnRate) {
    _saveRate(rvnRate);
    listen(
      'periodic',
      Stream.periodic(_rateWait),
      (_) async {
        print('in listen');
        await _save(await _rate(rvnRate));
      },
    );
  }

  Future<double> _rate(RVNRateInterface rvnRate) async =>
      await rvnRate.get() ??
      res.rates.primaryIndex
          .getOne(res.securities.RVN, res.securities.USD)
          ?.rate ??
      0.0; // instead of hardcoding a default we might disable the feature to see anything in USD on the front end...

  Future _save(double rate) async => await res.rates.save(Rate(
        base: res.securities.RVN,
        quote: res.securities.USD,
        rate: rate,
      ));

  Future _saveRate(RVNRateInterface rvnRate) async =>
      await _save(await _rate(rvnRate));
}
