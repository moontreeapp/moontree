part of 'setting.dart';

// bySettingName

String _settingNameToKey(SettingName name) => describeEnum(name);

class _SettingNameKey extends Key<Setting> {
  @override
  String getKey(Setting setting) => _settingNameToKey(setting.name);
}

extension BySettingNameMethodsForSetting on Index<_SettingNameKey, Setting> {
  Setting? getOne(SettingName name) =>
      getByKeyStr(_settingNameToKey(name)).firstOrNull;
}
