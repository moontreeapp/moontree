import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'asset.keys.dart';

class AssetReservoir extends Reservoir<_AssetIdKey, Asset> {
  late IndexMultiple<_SymbolKey, Asset> bySymbol;
  late IndexMultiple<_AssetTypeKey, Asset> byAssetType;

  AssetReservoir() : super(_AssetIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byAssetType = addIndexMultiple('assetType', _AssetTypeKey());
  }
}
