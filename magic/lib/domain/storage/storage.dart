import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey {
  xpubs,
  rate,
  setting,
  cache;

  String key([String? id]) {
    switch (this) {
      case StorageKey.cache:
        return 'cache:$id';
      case StorageKey.xpubs:
        return 'xpubs';
      case StorageKey.rate:
        return 'rate:$id';
      case StorageKey.setting:
        return 'setting:$id';
      default:
        return name;
    }
  }
}

extension ReadWriteExt on SharedPreferencesAsync {
  Future<void> write({required String key, required String value}) async =>
      await setString(key, value);
  Future<void> writeKey({
    required StorageKey key,
    required String value,
  }) async =>
      await setString(key.key(), value);
  Future<String?> read({required String key}) => getString(key);
  Future<String?> readKey({required StorageKey key}) => getString(key.key());
}
