import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart' show CommInt;
import 'package:client_front/infrastructure/cache/cache.dart';
import 'package:collection/collection.dart';

class CirculatingSatsCache {
  /// accepts a list of AssetMetadata objects and saves them as balances in cache
  static Future<void> put({
    required Chain chain,
    required Net net,
    required Iterable<CommInt> records,
  }) async =>
      Cache.save(
        records,
        'CirculatingSats',
        chain: chain,
        net: net,
      );

  /// gets list of AssetMetadata objects from cache
  static CommInt? get({
    required Chain chain,
    required Net net,
  }) =>
      pros.cache.byCirculatingSats
          .getAll(chain, net)
          .map((e) => Cache.read<CommInt>(e))
          .firstOrNull;
}
