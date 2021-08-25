import 'package:raven/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

String _paramsToKey(Security base, Security quote) =>
    '${base.symbol}:${base.securityType}:${quote.symbol}:${quote.securityType}';

/// example:
/// base: RVN
/// quote: USD
/// price: $0.13

/// what things will be priced in:
/// asset -> RVN
/// RVN -> USD (or major fiats)
/// USD -> other fiat (for obscure fiats)
class ExchangeRateReservoir extends Reservoir<String, Rate> {
  ExchangeRateReservoir([source])
      : super(source ?? HiveSource('rates'),
            (rate) => _paramsToKey(rate.base, rate.quote));

  Rate? getOne(Security base, Security quote) =>
      primaryIndex.getOne(_paramsToKey(base, quote));

  double assetToRVN(Security asset) {
    return getOne(asset, RVN)!.rate;
  }

  double get rvnToUSD => getOne(RVN, USD)?.rate ?? 0.0;

  double rvnToFiat(Security fiat) {
    return getOne(RVN, fiat)!.rate;
  }

  double fiatToFiat(Security fiatQuote, {Security fiatBase = USD}) {
    return getOne(fiatBase, fiatQuote)!.rate;
  }
}
