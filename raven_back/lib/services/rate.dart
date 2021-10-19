import 'package:raven/utils/rate.dart';
import 'package:raven/raven.dart';

class RateService {
  double assetToRVN(Security asset) =>
      rates.primaryIndex.getOne(asset, securities.RVN)?.rate ?? 0.0;

  double get rvnToUSD =>
      rates.primaryIndex.getOne(securities.RVN, securities.USD)?.rate ?? 0.0;

  double rvnToFiat(Security fiat) =>
      rates.primaryIndex.getOne(securities.RVN, fiat)?.rate ?? 0.0;

  double fiatToFiat(Security fiatQuote, {Security? fiatBase}) =>
      rates.primaryIndex.getOne(fiatBase ?? securities.USD, fiatQuote)?.rate ??
      0.0;

  Future saveRate() async {
    await rates.save(Rate(
      base: securities.RVN,
      quote: securities.USD,
      rate: await RVNtoFiat().get(),
    ));
  }

  BalanceUSD accountBalanceUSD(String accountId, List<Balance> holdings) {
    var totalRVNBalance = getTotalRVN(accountId, holdings);
    var usd = BalanceUSD(confirmed: 0.0, unconfirmed: 0.0);
    if (totalRVNBalance.value > 0) {
      var rate = rvnToUSD;
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
        security: securities.RVN,
        confirmed: balance.security == securities.RVN
            ? balance.confirmed
            : ((balance.confirmed / assetPercision) *
                    assetToRVN(balance.security))
                .round(),
        unconfirmed: balance.security == securities.RVN
            ? balance.unconfirmed
            : ((balance.unconfirmed / assetPercision) *
                    assetToRVN(balance.security))
                .round()));
    return accountBalancesAsRVN.fold(
        Balance(
          walletId: accountId,
          security: securities.RVN,
          confirmed: 0,
          unconfirmed: 0,
        ),
        (summing, balance) => summing + balance);
  }
}
