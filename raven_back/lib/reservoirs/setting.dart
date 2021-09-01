import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/setting_name.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/records/records.dart';

part 'setting.keys.dart';

final defaultSettings = {
  SettingName.Electrum_Url:
      Setting(name: SettingName.Electrum_Url, value: 'testnet.rvn.rocks'),
  SettingName.Electrum_Port:
      Setting(name: SettingName.Electrum_Port, value: 50002),
  SettingName.Account_Current:
      Setting(name: SettingName.Account_Current, value: '0'),
  SettingName.Account_Order:
      Setting(name: SettingName.Account_Order, value: '0'),
};

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir([source])
      : super(source ?? HiveSource('settings', defaults: defaultSettings),
            _SettingNameKey());

  List<String> get accountOrder {
    // requires account IDS to not have spaces in them...
    return primaryIndex.getOne(SettingName.Account_Order)!.value.split(' ');
  }

  void saveAccountOrder(List<String> accountIds) {
    save(Setting(name: SettingName.Account_Order, value: accountIds.join(' ')));
  }
}
