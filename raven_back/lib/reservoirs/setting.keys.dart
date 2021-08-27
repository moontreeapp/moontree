part of 'setting.dart';

// byAccount

String _settingNameToKey(SettingName name) => describeEnum(name);

class _SettingNameKey extends Key<Setting> {
  @override
  String getKey(Setting setting) => _settingNameToKey(setting.name);
}

extension BySettingNameMethodsForSetting on Index<_SettingNameKey, Setting> {
  Setting? getOne(SettingName name) {
    var settings = getByKeyStr(_settingNameToKey(name));
    return settings.isEmpty ? null : settings.first;
  }
}
