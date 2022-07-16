part of 'joins.dart';

extension SecurityHasOneAsset on Security {
  Asset? get asset => pros.assets.bySymbol.getOne(symbol);
}

extension SecurityHasOneRVNRate on Security {
  double get toRVNRate =>
      pros.rates.primaryIndex.getOne(this, pros.securities.RVN)?.rate ?? 0.0;
}

extension SecurityHasOneUSDRate on Security {
  double? get toUSDRate => pros.rates.primaryIndex
      .getOne(pros.securities.RVN, pros.securities.USD)
      ?.rate;
}
