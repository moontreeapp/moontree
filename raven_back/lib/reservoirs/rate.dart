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
  ExchangeRateReservoir() : super(_RateKey());

  /// logic moved to service...
}
