import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

/// even though this is called history, we only need current so it currently
/// returns just the current data.
class AssetMetadataHistoryCall extends ServerCall {
  late String symbol;
  late Chain chain;
  late Net net;
  AssetMetadataHistoryCall({
    String? symbol,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.symbol = symbol ?? pros.securities.coinOf(this.chain, this.net).symbol;
  }

  Future<server.AssetMetadataResponse> assetMetadataHistoryBy({
    //server.AssetMetadataResponse
    required String symbol,
    required Chaindata chain,
  }) async =>
      await runCall(() async => await client.metadata.get(
            symbol: symbol,
            chainName: chain.name,
            height: null,
          ));

  Future<server.AssetMetadataResponse> call() async {
    if (symbol == pros.securities.coinOf(chain, net).symbol) {
      switch (symbol) {
        case 'EVR':
          return server.AssetMetadataResponse(
            reissuable: false,
            totalSupply: coinsPerChain,
            divisibility: 8,
            frozen: false,
          );
        default:
          //case 'RVN':
          return server.AssetMetadataResponse(
            reissuable: false,
            totalSupply: coinsPerChain,
            divisibility: 8,
            frozen: false,
          );
      }
    }
    final server.AssetMetadataResponse history = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await assetMetadataHistoryBy(
            symbol: symbol,
            chain: ChainNet(chain, net).chaindata,
          );

    //if (history.length == 1 /*&& history.first.error != null*/) {
    //  // handle
    //  return [];
    //}
    return history;
  }
}

server.AssetMetadataResponse spoof() {
  return server.AssetMetadataResponse(
    reissuable: false,
    totalSupply: 100,
    divisibility: 4,
    frozen: false,
  );
}
