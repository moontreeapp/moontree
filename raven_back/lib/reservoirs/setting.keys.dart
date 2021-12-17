part of 'setting.dart';

// bySettingName

class _SettingNameKey extends Key<Setting> {
  @override
  String getKey(Setting setting) => setting.settingId;
}

extension BySettingNameMethodsForSetting on Index<_SettingNameKey, Setting> {
  Setting? getOne(SettingName name) =>
      getByKeyStr(Setting.settingKey(name)).firstOrNull;
}
