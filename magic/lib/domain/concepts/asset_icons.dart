import 'dart:convert';
import 'package:magic/domain/blockchain/blockchain.dart';

class AssetIcons {
  static const String _baseLogoPath = 'assets/asset_logos/';

  static final Map<String, dynamic> _assetInfo = {
    "DARKMEME": {
      "blockchain_name": "Evrmore",
      "logo_path": "darkmeme.png",
      "exchange": "",
      "fiat_pair": ""
    },
    // Add more assets here
  };

  static bool hasCustomIcon(String assetName, Blockchain blockchain) {
    print('Checking for custom icon: $assetName on ${blockchain.name}');
    final info = _assetInfo[assetName];
    return info != null && info['blockchain_name'] == blockchain.name;
  }

  static String? getIconPath(String assetName, Blockchain blockchain) {
    final info = _assetInfo[assetName];
    if (info != null && info['blockchain_name'] == blockchain.name) {
      return '$_baseLogoPath${info['logo_path']}';
    }
    return null;
  }

  static Map<String, dynamic>? getAssetInfo(String assetName) {
    return _assetInfo[assetName];
  }
}
