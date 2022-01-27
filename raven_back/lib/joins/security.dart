part of 'joins.dart';

extension SecurityHasOneAsset on Security {
  Asset? get asset => res.assets.bySymbol.getOne(symbol);
}
