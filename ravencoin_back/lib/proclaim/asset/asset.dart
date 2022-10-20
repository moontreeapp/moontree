import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'asset.keys.dart';

class AssetProclaim extends Proclaim<_IdKey, Asset> {
  late IndexMultiple<_AssetTypeKey, Asset> byAssetType;

  AssetProclaim() : super(_IdKey()) {
    byAssetType = addIndexMultiple('assetType', _AssetTypeKey());
  }
}
