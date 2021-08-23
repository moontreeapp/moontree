import 'package:raven/records/setting_name.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/records.dart';

class SettingReservoir extends Reservoir<SettingName, Setting> {
  SettingReservoir([source])
      : super(
            source ??
                HiveSource('settings', defaults: {
                  SettingName.Electrum_Url: 'testnet.rvn.rocks',
                  SettingName.Electrum_Port: 50002
                }),
            (setting) => setting.name);
}
