import 'package:raven/records.dart' as records;
import 'package:raven/models/rate.dart';
import 'package:raven/records/security.dart';
import 'package:raven/reservoir/reservoir.dart';

/// asset -> RVN
/// RVN -> USD (or major fiats)
/// USD -> other fiat (for obscure fiats)
class ExchangeRateReservoir
    extends Reservoir<List<Security>, records.Rate, Rate> {
  ExchangeRateReservoir() : super(HiveSource('conversion')) {
    var paramsToKey = (Security base, Security quote) => [base, quote];
    addPrimaryIndex((rate) => paramsToKey(rate.base, rate.quote));
  }

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
