part of 'joins.dart';

extension SecurityHasOneAsset on Security {
  Asset? get asset => res.assets.bySymbol.getOne(symbol);
}

extension SecurityHasOneRVNRate on Security {
  double get toRVNRate =>
      res.rates.primaryIndex.getOne(this, res.securities.RVN)?.rate ?? 0.0;
}

extension SecurityHasOneUSDRate on Security {
  double? get toUSDRate => res.rates.primaryIndex
      .getOne(res.securities.RVN, res.securities.USD)
      ?.rate;
}
