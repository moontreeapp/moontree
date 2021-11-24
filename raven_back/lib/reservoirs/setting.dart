import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/utils/enum.dart' show describeEnum;
import 'package:raven/records/records.dart';

part 'setting.keys.dart';

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir() : super(_SettingNameKey());

  static Map<String, Setting> get defaults => {
        SettingName.Electrum_Domain0: Setting(
            name: SettingName.Electrum_Domain0, value: 'testnet.rvn.rocks'),
        SettingName.Electrum_Port0:
            Setting(name: SettingName.Electrum_Port0, value: 50002),
        SettingName.Electrum_Domain1: Setting(
            name: SettingName.Electrum_Domain1, value: 'testnet.rvn.rocks'),
        SettingName.Electrum_Port1:
            Setting(name: SettingName.Electrum_Port1, value: 50002),
        SettingName.Electrum_Domain2: Setting(
            name: SettingName.Electrum_Domain2, value: 'testnet.rvn.rocks'),
        SettingName.Electrum_Port2:
            Setting(name: SettingName.Electrum_Port2, value: 50002),
        SettingName.Account_Current:
            Setting(name: SettingName.Account_Current, value: '0'),
        SettingName.Account_Preferred:
            Setting(name: SettingName.Account_Preferred, value: '0'),
      }.map((settingName, setting) =>
          MapEntry(describeEnum(settingName), setting));

  String get preferredAccountId =>
      primaryIndex.getOne(SettingName.Account_Preferred)!.value;

  String get currentAccountId =>
      primaryIndex.getOne(SettingName.Account_Current)!.value;

  String? get localPath => primaryIndex.getOne(SettingName.Local_Path)?.value;

  Future savePreferredAccountId(String accountId) async => await save(
      Setting(name: SettingName.Account_Preferred, value: accountId));

  Future setCurrentAccountId([String? accountId]) async => await save(Setting(
      name: SettingName.Account_Current,
      value: accountId ?? preferredAccountId));
}
