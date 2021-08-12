import 'dart:async';

import 'package:raven/records/balance.dart';
import 'package:raven/records/rate.dart';
import 'package:raven/records/security.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/balance.dart';
import 'package:raven/reservoirs/rate.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/rate.dart';

class ExchangeRateService extends Service {
  BalanceReservoir balances;
  ExchangeRateReservoir rates;

  late StreamSubscription<List<Change>> listener;

  ExchangeRateService(this.balances, this.rates) : super();

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
    rates.save(Rate(base: RVN, quote: USD, rate: await RVNtoFiat().get()));
  }

  double get rvnToUSD => rates.rvnToUSD;

  BalanceUSD accountBalanceUSD(String accountId) {
    var totalRVNBalance = getTotalRVN(accountId);
    var usd;
    if (totalRVNBalance.value > 0) {
      var rate = rates.rvnToUSD;
      usd = BalanceUSD(
          confirmed: (totalRVNBalance.confirmed * rate).toDouble(),
          unconfirmed: (totalRVNBalance.confirmed * rate).toDouble());
    }
    return usd;
  }

  Balance getTotalRVN(String accountId) {
    var accountBalances = balances.byAccount.getAll(accountId);
    var accountBalancesAsRVN = accountBalances.map((balance) => Balance(
        accountId: accountId,
        security: RVN,
        confirmed: balance.security == RVN
            ? balance.confirmed
            : (balance.confirmed * rates.assetToRVN(balance.security)).round(),
        unconfirmed: balance.security == RVN
            ? balance.unconfirmed
            : (balance.unconfirmed * rates.assetToRVN(balance.security))
                .round()));
    return accountBalancesAsRVN.fold(
        Balance(
          accountId: accountId,
          security: RVN,
          confirmed: 0,
          unconfirmed: 0,
        ),
        (summing, balance) => summing + balance);
  }
}
