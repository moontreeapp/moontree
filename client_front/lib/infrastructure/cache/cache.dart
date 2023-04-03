/// cache is responsible for saving data to cache. things we save to cache are
/// saved in hive boxes so they can be persistent across sessions so much of
/// what cache is tasked to do is translate the server object to the local
/// object and save to cache. repos call this.

/// IMPORTANT:
/// instead of caching the domain as we did in v1 we are caching things in the
/// same structure as the server data, then translate to the domain after we get
/// the data from either cache or server.
import 'dart:typed_data';
import 'dart:convert';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart'
    show SerializableEntity;
import 'package:client_back/server/src/protocol/protocol.dart' show Protocol;
import 'package:moontree_utils/extensions/bytedata.dart';
import 'package:moontree_utils/extensions/string.dart';

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
    bool saveSymbols = false,
    bool saveTxHashes = false,
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
            symbol: symbol ?? (saveSymbols ? (record as dynamic).symbol : null),
            txHash: txHash ??
                (saveTxHashes
                    ? ((record as dynamic).hash as ByteData).toHex()
                    : null),
            height: saveHeights ? (record as dynamic).height : null,
          )
      ]);

  static T read<T>(CachedServerObject x) => Protocol().deserialize(
      json.decode(
        x.json,
        //reviver: (key, value) {
        //  // convert String values back to their ByteData or DateTime by key
        //  if (['memo', 'associatedData'].contains(key) && value is String) {
        //    return value.hexToByteData;
        //  }
        //  if (['datetime'].contains(key) && value is String) {
        //    return DateTime.parse(value);
        //  }
        //  return value;
        //},
      ),
      T);
}
