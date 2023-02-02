import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show AssetMetadata;
import 'package:client_front/infrastructure/cache/asset_metadata.dart';
import 'package:client_front/infrastructure/calls/asset_metadata.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class AssetMetadataHistoryRepo extends Repository<Iterable<AssetMetadata>> {
  late String symbol;
  late Chain chain;
  late Net net;

  AssetMetadataHistoryRepo({
    String? symbol,
    Security? security,
    Chain? chain,
    Net? net,
  }) : super([] as Iterable<AssetMetadata>) {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.symbol = symbol ??
        security?.symbol ??
        pros.securities.coinOf(this.chain, this.net).symbol;
  }

  @override
  bool detectServerError(dynamic resultServer) => resultServer.length == 0;

  @override
  String extractError(dynamic resultServer) => resultServer.first.error!;

  @override
  Future<Iterable<AssetMetadata>> fromServer() async =>
      AssetMetadataHistoryCall(chain: chain, net: net, symbol: symbol)();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  Iterable<AssetMetadata>? fromLocal() =>
      AssetsCache.get(chain: chain, net: net, symbol: symbol);

  @override
  Future<void> save() async => AssetsCache.put(
        symbol: symbol,
        chain: chain,
        net: net,
        records: results,
      );
}
