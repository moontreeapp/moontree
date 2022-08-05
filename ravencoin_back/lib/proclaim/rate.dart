import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:proclaim/proclaim.dart';

part 'rate.keys.dart';

/// example:
/// base: RVN
/// quote: USD
/// price: $0.13

/// what things will be priced in:
/// asset -> RVN
/// RVN -> USD (or major fiats)
/// USD -> other fiat (for obscure fiats)
class ExchangeRateProclaim extends Proclaim<_RateKey, Rate> {
  ExchangeRateProclaim() : super(_RateKey());
}