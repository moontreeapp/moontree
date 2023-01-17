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

  Future<List<server.SerializableEntity>> assetMetadataHistoryBy({
    //server.AssetMetadata
    required String symbol,
    required Chaindata chain,
  }) async =>
      await client.metadata.get(
        symbol: symbol,
        chainName: chain.name,
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
  if (symbol == pros.securities.coinOf(chain, net).symbol) {
    switch (symbol) {
      case 'EVR':
        return [
          server.AssetMetadata(
            reissuable: false,
            totalSupply: coinsPerChain,
            divisibility: 8,
            frozen: false,
            voutId: 0,
          )
        ];
      default:
        //case 'RVN':
        return [
          server.AssetMetadata(
            reissuable: false,
            totalSupply: coinsPerChain,
            divisibility: 8,
            frozen: false,
            voutId: 0,
          )
        ];
    }
  }
  final List<server.SerializableEntity> history =

      /// MOCK SERVER
      await Future.delayed(Duration(seconds: 1), spoofAssetMetadata);

  /// SERVER
  //await AssetMetadataHistory().assetMetadataHistoryBy(
  //    symbol: symbol, chain: ChainNet(chain, net).chaindata);

  if (history.length == 1 && history.first is server.EndpointError) {
    // handle
    return [];
  }
  return [for (final hist in history) hist as server.AssetMetadata];
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
