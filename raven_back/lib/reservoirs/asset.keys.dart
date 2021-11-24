part of 'asset.dart';

// primary key

class _AssetIdKey extends Key<Asset> {
  @override
  String getKey(Asset asset) => asset.assetId;
}

extension ByIdMethodsForAsset on Index<_AssetIdKey, Asset> {
  Asset? getOne(String assetId) => getByKeyStr(assetId).firstOrNull;
}

// bySymbol
class _SymbolKey extends Key<Asset> {
  @override
  String getKey(Asset asset) => asset.symbol;
}

extension BySymbolMethodsForAsset on Index<_SymbolKey, Asset> {
  Asset? getOne(String symbol) => getByKeyStr(symbol).firstOrNull;
}
