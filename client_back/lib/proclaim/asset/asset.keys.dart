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

// byAssetType

class _AssetTypeKey extends Key<Asset> {
  @override
  String getKey(Asset asset) => asset.assetTypeName;
}

extension ByAssetTypeMethodsForAsset on Index<_AssetTypeKey, Asset> {
  List<Asset> getAll(AssetType assetType) => getByKeyStr(assetType.name);
}
