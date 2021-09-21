import 'package:raven/utils/rate.dart';
import 'package:raven/raven.dart';

class RateService {
  Future saveRate() async {
    await rates.save(Rate(
      base: RVN,
      quote: USD,
      rate: await RVNtoFiat().get(),
    ));
  }

  double get rvnToUSD => rates.rvnToUSD;

  BalanceUSD accountBalanceUSD(String accountId, List<Balance> holdings) {
    var totalRVNBalance = getTotalRVN(accountId, holdings);
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

  Balance getTotalRVN(String accountId, List<Balance> holdings) {
    var assetPercision = 100000000; /* get percision of asset...  */

    /// per wallet...
    var accountBalancesAsRVN = holdings.map((balance) => Balance(
        walletId: accountId,
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
          walletId: accountId,
          security: RVN,
          confirmed: 0,
          unconfirmed: 0,
        ),
        (summing, balance) => summing + balance);
  }
}
