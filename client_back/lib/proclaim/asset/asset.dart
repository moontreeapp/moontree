import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';

part 'asset.keys.dart';

class AssetProclaim extends Proclaim<_IdKey, Asset> {
  late IndexMultiple<_SymbolTypeKey, Asset> bySymbolType;

  AssetProclaim() : super(_IdKey()) {
    bySymbolType = addIndexMultiple('assetType', _SymbolTypeKey());
  }
}
