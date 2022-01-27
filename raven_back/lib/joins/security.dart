part of 'joins.dart';

extension SecurityHasOneAsset on Security {
  Asset? get asset => globals.res.assets.bySymbol.getOne(symbol);
}
