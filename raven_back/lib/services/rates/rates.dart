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
      var percision = 100000000;
      usd = BalanceUSD(
          confirmed:
              ((totalRVNBalance.confirmed / percision) * rate).toDouble(),
          unconfirmed:
              ((totalRVNBalance.unconfirmed / percision) * rate).toDouble());
    }
    return usd;
  }

  /// todo unit test
  Balance getTotalRVN(String accountId) {
    var accountBalances = balances.byAccount.getAll(accountId);
    var assetPercision = 100000000; /* get percision of asset...  */
    var accountBalancesAsRVN = accountBalances.map((balance) => Balance(
        accountId: accountId,
        security: RVN,
        confirmed: balance.security == RVN
            ? balance.confirmed
            : ((balance.confirmed / assetPercision) *
                    rates.assetToRVN(balance.security))
                .round(),
        unconfirmed: balance.security == RVN
            ? balance.unconfirmed
            : ((balance.unconfirmed / assetPercision) *
                    rates.assetToRVN(balance.security))
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
