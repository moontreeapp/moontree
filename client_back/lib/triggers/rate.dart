import 'dart:async';

import 'package:client_back/client_back.dart';
import 'package:client_back/utilities/rate.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class RateWaiter extends Trigger {
  // should be pushed to clients on change instead
  static const Duration _rateWait = Duration(minutes: 10);

  void init(RVNtoFiat rvnRate) {
    _saveRate(rvnRate);
    when(
      thereIsA: Stream<dynamic>.periodic(_rateWait),
      doThis: (_) async => _saveRate(rvnRate),
    );
  }

  Future<double> _rate(RVNtoFiat rvnRate) async =>
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

  Future<Change<Rate>?> _saveRate(RVNtoFiat rvnRate) async =>
      _save(await _rate(rvnRate));
}
