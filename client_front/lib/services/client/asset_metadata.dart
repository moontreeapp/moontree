import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

/// even though this is called history, we only need current so it currently
/// returns just the current data.
class AssetMetadataHistory {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;

  AssetMetadataHistory() : client = server.Client('$moontreeUrl/');

  Future<List<server.AssetMetadata>> assetMetadataHistoryBy({
    required String symbol,
    required Chaindata chain,
  }) async =>
      await client.metadata.get(
        symbol: symbol,
        chain: chain.name,
        height: null,
      );
}

Future<List<server.AssetMetadata>> discoverAssetMetadataHistory({
  Wallet? wallet,
  String? symbol,
  Security? security,
}) async {
  Chain chain = security?.chain ?? Current.chain;
  Net net = security?.net ?? Current.net;
  symbol ??= security?.symbol ?? pros.securities.coinOf(chain, net).symbol;
  final List<server.AssetMetadata> history =

      /// MOCK SERVER
      await Future.delayed(Duration(seconds: 1), spoofAssetMetadata);

  /// SERVER
  //await  AssetMetadataHistory().assetMetadataHistoryBy(
  //    symbol: symbol, chain: ChainNet(chain, net).chaindata);

  return history;
}

List<server.AssetMetadata> spoofAssetMetadata() {
  final views = <server.AssetMetadata>[
    server.AssetMetadata(
      reissuable: false,
      totalSupply: 100,
      divisibility: 4,
      frozen: false,
      voutId: 1,
    ),
  ];

  return views;
}
