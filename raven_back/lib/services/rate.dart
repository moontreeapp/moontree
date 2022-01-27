import 'package:raven_back/utils/rate.dart';
import 'package:raven_back/raven_back.dart';

class RateService {
  double? assetToRVN(Security asset, {double? defaultRate}) =>
      res.rates.primaryIndex.getOne(asset, res.securities.RVN)?.rate ??
      defaultRate;

  double? get rvnToUSD => res.rates.primaryIndex
      .getOne(res.securities.RVN, res.securities.USD)
      ?.rate;

  double? rvnToFiat(Security fiat, {double? defaultRate}) =>
      res.rates.primaryIndex.getOne(res.securities.RVN, fiat)?.rate ??
      defaultRate;

  double? fiatToFiat(
    Security fiatQuote, {
    Security? fiatBase,
    double? defaultRate,
  }) =>
      res.rates.primaryIndex
          .getOne(fiatBase ?? res.securities.USD, fiatQuote)
          ?.rate ??
      defaultRate;

  Future saveRate() async {
    await res.rates.save(Rate(
      base: res.securities.RVN,
      quote: res.securities.USD,
      rate: await RVNtoFiat().get() ??
          res.rates.primaryIndex
              .getOne(res.securities.RVN, res.securities.USD)
              ?.rate ??
          0.1, // instead of hardcoding a default we might disable the feature to see anything in USD on the front end...
    ));
  }

  BalanceUSD? accountBalanceUSD(String accountId, List<Balance> holdings) {
    var totalRVNBalance = getTotalRVN(accountId, holdings);
    var usd = BalanceUSD(confirmed: 0.0, unconfirmed: 0.0);
    if (totalRVNBalance.value > 0) {
      var rate = rvnToUSD;
      if (rate == null) return null;
      var divisor = 100000000;
      usd = BalanceUSD(
          confirmed: ((totalRVNBalance.confirmed / divisor) * rate).toDouble(),
          unconfirmed:
              ((totalRVNBalance.unconfirmed / divisor) * rate).toDouble());
    }
    return usd;
  }

  Balance getTotalRVN(String accountId, List<Balance> holdings) {
    var assetPercision = 100000000; /* get divisor of asset...  */

    /// per wallet...
    var accountBalancesAsRVN = holdings.map((balance) => Balance(
        walletId: accountId,
        security: res.securities.RVN,
        confirmed: balance.security == res.securities.RVN
            ? balance.confirmed
            : ((balance.confirmed / assetPercision) *
                    assetToRVN(balance.security, defaultRate: 0.0)!)
                .round(),
        unconfirmed: balance.security == res.securities.RVN
            ? balance.unconfirmed
            : ((balance.unconfirmed / assetPercision) *
                    assetToRVN(balance.security, defaultRate: 0.0)!)
                .round()));
    return accountBalancesAsRVN.fold(
        Balance(
          walletId: accountId,
          security: res.securities.RVN,
          confirmed: 0,
          unconfirmed: 0,
        ),
        (summing, balance) => summing + balance);
  }
}
