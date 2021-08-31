import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'rate.keys.dart';

/// example:
/// base: RVN
/// quote: USD
/// price: $0.13

/// what things will be priced in:
/// asset -> RVN
/// RVN -> USD (or major fiats)
/// USD -> other fiat (for obscure fiats)
class ExchangeRateReservoir extends Reservoir<_RateKey, Rate> {
  ExchangeRateReservoir([source])
      : super(source ?? HiveSource('rates'), _RateKey());

  double assetToRVN(Security asset) =>
      primaryIndex.getOne(asset, RVN)?.rate ?? 0.0;

  double get rvnToUSD => primaryIndex.getOne(RVN, USD)?.rate ?? 0.0;

  double rvnToFiat(Security fiat) =>
      primaryIndex.getOne(RVN, fiat)?.rate ?? 0.0;

  double fiatToFiat(Security fiatQuote, {Security fiatBase = USD}) =>
      primaryIndex.getOne(fiatBase, fiatQuote)?.rate ?? 0.0;
}
