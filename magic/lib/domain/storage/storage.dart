import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey {
  xpubs,
  rate,
  cache;

  String key([String? id]) {
    switch (this) {
      case StorageKey.cache:
        return 'cache:$id';
      case StorageKey.xpubs:
        return 'xpubs';
      case StorageKey.rate:
        return 'rate:$id';
      default:
        return name;
    }
  }
}

extension ReadWriteExt on SharedPreferences {
  Future<bool> write({required String key, required String value}) async =>
      await setString(key, value);
  Future<bool> writeKey({
    required StorageKey key,
    required String value,
  }) async =>
      await setString(key.key(), value);
  String? read({required String key}) => getString(key);
  String? readKey({required StorageKey key}) => getString(key.key());
}
