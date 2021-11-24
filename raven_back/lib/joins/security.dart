part of 'joins.dart';

extension SecurityHasOneAsset on Security {
  Asset? get asset => globals.assets.bySymbol.getOne(symbol);
}
