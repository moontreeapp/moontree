part of 'rate.dart';

// primary key
class _RateKey extends Key<Rate> {
  @override
  String getKey(Rate rate) => rate.rateId;
}

extension ByRateMethodsForRate on Index<_RateKey, Rate> {
  Rate? getOne(Security base, Security quote) =>
      getByKeyStr(Rate.key(base, quote)).firstOrNull;
}
