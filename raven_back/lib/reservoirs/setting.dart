import 'package:raven/records/setting_name.dart';
import 'package:reservoir/reservoir.dart';
import 'package:raven/records.dart';

class SettingReservoir extends Reservoir<String, Setting> {
  SettingReservoir([source])
      : super(
            source ??
                HiveSource('settings', defaults: {
                  SettingName.Electrum_Url: Setting(
                      name: SettingName.Electrum_Url,
                      value: 'testnet.rvn.rocks'),
                  SettingName.Electrum_Port:
                      Setting(name: SettingName.Electrum_Port, value: 50002),
                  SettingName.Current_Account:
                      Setting(name: SettingName.Current_Account, value: '0'),
                }),
            (setting) => setting.name.endingToString());

  Setting? getOne(SettingName name) =>
      primaryIndex.getOne(name.endingToString());
}
