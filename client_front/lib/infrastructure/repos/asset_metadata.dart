import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show AssetMetadataResponse;
import 'package:client_front/infrastructure/cache/asset_metadata.dart';
import 'package:client_front/infrastructure/calls/asset_metadata.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

/*
kralverde — Server definitions of metadata memos
Associated data is whatever is associated with the asset (ipfs hash). 
Asset memo is only for asset transfers, and memo is for OP_RETURN messages
*/

class AssetMetadataHistoryRepo extends Repository<AssetMetadataResponse> {
  late String symbol;
  late Chain chain;
  late Net net;

  AssetMetadataHistoryRepo({
    String? symbol,
    Security? security,
    Chain? chain,
    Net? net,
  }) : super(generateFallback) {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.symbol = symbol ??
        security?.symbol ??
        pros.securities.coinOf(this.chain, this.net).symbol;
  }
  static AssetMetadataResponse generateFallback([String? error]) =>
      AssetMetadataResponse(
        error: 'generated fallback metadata',
        reissuable: false,
        totalSupply: 0,
        divisibility: 0,
        frozen: false,
      );

  @override
  bool detectServerError(dynamic resultServer) => resultServer.error != null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  @override
  String extractError(dynamic resultServer) => 'no result';

  @override
  Future<AssetMetadataResponse> fromServer() async =>
      AssetMetadataHistoryCall(chain: chain, net: net, symbol: symbol)();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  AssetMetadataResponse? fromLocal() =>
      AssetsCache.get(chain: chain, net: net, symbol: symbol)?.firstOrNull;

  @override
  Future<void> save() async => AssetsCache.put(
        symbol: symbol,
        chain: chain,
        net: net,
        records: [results],
      );
}
