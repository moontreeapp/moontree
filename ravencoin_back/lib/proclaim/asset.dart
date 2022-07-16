import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'asset.keys.dart';

class AssetProclaim extends Proclaim<_AssetIdKey, Asset> {
  late IndexMultiple<_SymbolKey, Asset> bySymbol;
  late IndexMultiple<_AssetTypeKey, Asset> byAssetType;

  AssetProclaim() : super(_AssetIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byAssetType = addIndexMultiple('assetType', _AssetTypeKey());
  }
}
