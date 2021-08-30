import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/setting_name.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/records.dart';

part 'setting.keys.dart';

final defaultSettings = {
  SettingName.Electrum_Url:
      Setting(name: SettingName.Electrum_Url, value: 'testnet.rvn.rocks'),
  SettingName.Electrum_Port:
      Setting(name: SettingName.Electrum_Port, value: 50002),
  SettingName.Current_Account:
      Setting(name: SettingName.Current_Account, value: '0'),
};

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir([source])
      : super(source ?? HiveSource('settings', defaults: defaultSettings),
            _SettingNameKey());
}
