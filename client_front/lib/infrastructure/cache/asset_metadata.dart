import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show AssetMetadata;
import 'package:client_front/infrastructure/cache/cache.dart';

class AssetsCache {
  /// accepts a list of AssetMetadata objects and saves them as balances in cache
  static Future<void> put({
    required String symbol,
    required Chain chain,
    required Net net,
    required Iterable<AssetMetadata> records,
  }) async =>
      Cache.save(
        records,
        'AssetMetadata',
        symbol: symbol,
        chain: chain,
        net: net,
      );

  /// gets list of AssetMetadata objects from cache
  static Iterable<AssetMetadata>? get({
    required String symbol,
    required Chain chain,
    required Net net,
  }) =>
      pros.cache.byAssetMetadata
          .getAll(symbol, chain, net)
          .map((e) => Cache.read<AssetMetadata>(e));
}
