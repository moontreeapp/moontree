part of 'rate.dart';

// primary key

String _rateToKey(Security base, Security quote) =>
    '${base.securityId}:${quote.securityId}';

class _RateKey extends Key<Rate> {
  @override
  String getKey(Rate rate) => _rateToKey(rate.base, rate.quote);
}

extension ByRateMethodsForRate on Index<_RateKey, Rate> {
  Rate? getOne(Security base, Security quote) =>
      getByKeyStr(_rateToKey(base, quote)).firstOrNull;
}
