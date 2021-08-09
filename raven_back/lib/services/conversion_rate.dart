import 'dart:async';

import 'package:raven/models/balance.dart';
import 'package:raven/models/rate.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/balance.dart';
import 'package:raven/reservoirs/rate.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/rate.dart';

class ConversionRateService extends Service {
  BalanceReservoir balances;
  ConversionRateReservoir rates;

  late StreamSubscription<List<Change>> listener;

  ConversionRateService(this.balances, this.rates) : super();

  @override
  Future init() async {
    /// get the conversion rate...
    // on open
    // on manual refresh
    //listener = conversions.changes.listen(saveRate);
    await saveRate();
  }

  @override
  void deinit() {
    listener.cancel();
  }

  Future saveRate() async {
    rates.save(
        Rate(from: '', to: 'usd', rate: await RVNtoFiat().get(), fiat: true));
  }

  double get rvnToUSD => rates.rvnToUSD;

  BalanceUSD accountBalanceUSD(String accountId) {
    var rvn = balances.getTotalRVN(accountId);
    var usd;
    if (rvn.value > 0) {
      var rate = rates.rvnToUSD;
      usd = BalanceUSD(
          confirmed: (rvn.confirmed * rate).toDouble(),
          unconfirmed: (rvn.confirmed * rate).toDouble());
    }
    return usd;
  }
}
