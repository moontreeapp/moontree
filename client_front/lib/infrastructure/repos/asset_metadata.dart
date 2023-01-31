import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/cache/asset_metadata.dart';
import 'package:client_front/infrastructure/calls/asset_metadata.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class AssetMetadataHistoryRepo extends Repository {
  late Wallet wallet;
  late String symbol;
  late Security security;
  late Chain chain;
  late Net net;
  late List<protocol.AssetMetadata> results;
  AssetMetadataHistoryRepo({
    Wallet? wallet,
    String? symbol,
    Security? security,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.symbol = symbol ??
        security?.symbol ??
        pros.securities.coinOf(this.chain, this.net).symbol;
  }

  /// gets values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  @override
  Future<List<protocol.AssetMetadata>> get() async {
    final resultServer = await fromServer();
    if (resultServer.length == 0) {
      errors[RepoSource.server] = 'none';
      final resultCache = fromLocal();
      if (resultCache == null) {
        errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      } else {
        results = resultCache;
      }
    } else {
      results = resultServer;
      save();
    }
    return resultServer;
  }

  @override
  Future<List<protocol.AssetMetadata>> fromServer() async =>
      AssetMetadataHistoryCall(
        wallet: wallet,
        chain: chain,
        net: net,
        symbol: symbol,
        security: security,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  List<protocol.AssetMetadata>? fromLocal() => null;

  @override
  Future<void> save() async => AssetCache.put(
        symbol: symbol,
        chain: chain,
        net: net,
        records: results,
      );
}
