import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  rate,
  cache;

  String key([String? id]) {
    switch (this) {
      case PreferenceKey.cache:
        return 'cache-$id';
      case PreferenceKey.rate:
        return 'rate-$id';
      default:
        return name;
    }
  }
}

extension ReadWriteExt on SharedPreferences {
  Future<bool> write({required String key, required String value}) async =>
      await setString(key, value);
  Future<bool> writeKey(
          {required PreferenceKey key, required String value}) async =>
      await setString(key.key(), value);
  String? read({required String key}) => getString(key);
  String? readKey({required PreferenceKey key}) => getString(key.key());
}
