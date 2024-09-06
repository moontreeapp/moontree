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
    "CEASAR": {
      "blockchain_name": "Evrmore",
      "logo_path": "ceasar.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "EVRSTER": {
      "blockchain_name": "Evrmore",
      "logo_path": "evrster.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "JACKDAW": {
      "blockchain_name": "Evrmore",
      "logo_path": "jackdaw.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "SATORI": {
      "blockchain_name": "Evrmore",
      "logo_path": "satori.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "CATE": {
      "blockchain_name": "Evrmore",
      "logo_path": "cate.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "CATE": {
      "blockchain_name": "Ravencoin",
      "logo_path": "cate.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "LITTLEWARRIORS": {
      "blockchain_name": "Evrmore",
      "logo_path": "little_warriors.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "WOJCOIN": {
      "blockchain_name": "Evrmore",
      "logo_path": "wojcoin.png",
      "exchange": "",
      "fiat_pair": ""
    },
    "ZEN": {
      "blockchain_name": "Evrmore",
      "logo_path": "zen.png",
      "exchange": "",
      "fiat_pair": ""
    },
    // * Add more assets here
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
