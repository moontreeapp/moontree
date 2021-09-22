import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/setting_name.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/records/records.dart';

part 'setting.keys.dart';

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir() : super(_SettingNameKey());

  static Map<SettingName, Setting> get defaultSettings => {
        SettingName.Electrum_Url:
            Setting(name: SettingName.Electrum_Url, value: 'testnet.rvn.rocks'),
        SettingName.Electrum_Port:
            Setting(name: SettingName.Electrum_Port, value: 50002),
        SettingName.Account_Current:
            Setting(name: SettingName.Account_Current, value: '0'),
        SettingName.Account_Preferred:
            Setting(name: SettingName.Account_Preferred, value: '0'),
      };

  String get preferredAccountId =>
      primaryIndex.getOne(SettingName.Account_Preferred)!.value;

  String get currentAccountId =>
      primaryIndex.getOne(SettingName.Account_Current)!.value;

  /// from reservoir now
  //String get hashedSaltedPassword =>
  //    primaryIndex.getOne(SettingName.Password_SaltedHash)!.value;

  Future savePreferredAccountId(String accountId) async => await save(
      Setting(name: SettingName.Account_Preferred, value: accountId));

  Future setCurrentAccountId([String? accountId]) async => await save(Setting(
      name: SettingName.Account_Current,
      value: accountId ?? preferredAccountId));
}
