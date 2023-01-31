/// cache is responsible for saving data to cache. things we save to cache are
/// saved in hive boxes so they can be persistent across sessions so much of
/// what cache is tasked to do is translate the server object to the local
/// object and save to cache. repos call this.

/// IMPORTANT:
/// instead of caching the domain as we did in v1 we are caching things in the
/// same structure as the server data, then translate to the domain after we get
/// the data from either cache or server.
import 'dart:convert';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart'
    show SerializableEntity;
import 'package:client_back/server/src/protocol/protocol.dart' show Protocol;

class Cache {
  /// saves records to cache
  static Future<void> save(
    Iterable<SerializableEntity> records,
    String type, {
    String? walletId,
    String? symbol,
    Chain? chain,
    Net? net,
    String? txHash,
    bool saveHeights = false,
  }) async =>
      pros.cache.saveAll([
        for (final SerializableEntity record in records)
          CachedServerObject.from(
            record,
            type,
            walletId: walletId,
            chain: chain,
            net: net,
            symbol: symbol,
            txHash: txHash,
            height: saveHeights ? (record as dynamic).height : null,
          )
      ]);

  static T read<T>(CachedServerObject x) =>
      Protocol().deserialize(json.decode(x.json), T);
}
