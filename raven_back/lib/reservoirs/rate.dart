import 'package:raven/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

List<Security> _paramsToKey(Security base, Security quote) => [base, quote];

/// asset -> RVN
/// RVN -> USD (or major fiats)
/// USD -> other fiat (for obscure fiats)
class ExchangeRateReservoir extends Reservoir<List<Security>, Rate> {
  ExchangeRateReservoir([source])
      : super(source ?? HiveSource('rates'),
            (rate) => _paramsToKey(rate.base, rate.quote));

  double assetToRVN(Security asset) {
    return get([asset, RVN])!.rate;
  }

  double get rvnToUSD => get([RVN, USD])!.rate;

  double rvnToFiat(Security fiat) {
    return get([RVN, fiat])!.rate;
  }

  double fiatToFiat(Security fiatQuote, {Security fiatBase = USD}) {
    return get([fiatBase, fiatQuote])!.rate;
  }
}
