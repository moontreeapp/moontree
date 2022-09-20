part of 'rate.dart';

// primary key

class _RateKey extends Key<Rate> {
  @override
  String getKey(Rate rate) => rate.id;
}

extension ByRateMethodsForRate on Index<_RateKey, Rate> {
  Rate? getOne(Security base, Security quote) =>
      getByKeyStr(Rate.rateKey(base, quote)).firstOrNull;
}
