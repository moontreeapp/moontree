import 'package:raven/utils/rate.dart';
import 'package:raven/services/service.dart';
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';

class RatesService extends Service {
  late final BalanceReservoir balances;
  late final ExchangeRateReservoir rates;

  RatesService(this.balances, this.rates) : super();

  Future saveRate() async {
    await rates.save(Rate(
      base: RVN,
      quote: USD,
      rate: await RVNtoFiat().get(),
    ));
  }

  double get rvnToUSD => rates.rvnToUSD;

  BalanceUSD accountBalanceUSD(String accountId) {
    var totalRVNBalance = getTotalRVN(accountId);
    var usd = BalanceUSD(confirmed: 0.0, unconfirmed: 0.0);
    if (totalRVNBalance.value > 0) {
      var rate = rates.rvnToUSD;
      usd = BalanceUSD(
          confirmed: (totalRVNBalance.confirmed * rate).toDouble(),
          unconfirmed: (totalRVNBalance.unconfirmed * rate).toDouble());
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
