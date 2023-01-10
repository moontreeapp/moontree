part of 'asset.dart';

// primary key

class _IdKey extends Key<Asset> {
  @override
  String getKey(Asset asset) => asset.id;
}

extension ByIdMethodsForAsset on Index<_IdKey, Asset> {
  Asset? getOneById(String id) => getByKeyStr(id).firstOrNull;
  Asset? getOne(String symbol, Chain chain, Net net) =>
      getByKeyStr(Asset.key(symbol, chain, net)).firstOrNull;
}

// bySymbolType

class _SymbolTypeKey extends Key<Asset> {
  @override
  String getKey(Asset asset) => asset.symbolTypeName;
}

extension BySymbolTypeMethodsForAsset on Index<_SymbolTypeKey, Asset> {
  List<Asset> getAll(SymbolType assetType) => getByKeyStr(assetType.name);
}
