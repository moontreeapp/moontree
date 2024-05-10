import 'dart:convert';
import 'package:magic/domain/concepts/cache.dart';
import 'package:magic/domain/server/serverv2_client.dart'
    show SerializableEntity;
import 'package:magic/domain/server/protocol/protocol.dart' show Protocol;
import 'package:magic/services/services.dart';

class Cache {
  static Future<void> save({
    required String key,
    required String type,
    required Iterable<SerializableEntity> records,
  }) async =>
      storage.write(
          key: 'cache-$key',
          value:
              jsonEncode(records.map((r) => CachedServerObject.from(r, type))));

  static Future<String?> read({required String key}) async =>
      await storage.read(key: 'cache-$key');

  static Future<T?> readAs<T>({required String key}) async => Cache.build<T>(
      CachedServerObject.read(await storage.read(key: 'cache-$key') ??
          '{"type": "null", "json": "null"}'));

  static T build<T>(CachedServerObject x) =>
      Protocol().deserialize(json.decode(x.json), T);
}
