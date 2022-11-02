part of 'setting.dart';

// bySettingName

class _IdKey extends Key<Setting> {
  @override
  String getKey(Setting setting) => setting.id;
}

extension BySettingNameMethodsForSetting on Index<_IdKey, Setting> {
  Setting? getOne(SettingName name) =>
      getByKeyStr(Setting.key(name)).firstOrNull;

  List<Setting> getAll(SettingName name) => getByKeyStr(Setting.key(name));
}
