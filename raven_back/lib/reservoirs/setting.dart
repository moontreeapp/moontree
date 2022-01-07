import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/records/records.dart';

part 'setting.keys.dart';

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir() : super(_SettingNameKey());

  /// some other options for testing before we get our own electrum server up:
  // mainnet electrum3.rvn.rocks
  // testnet rvn4lyfe.com:50003

  static final String defaultUrl = 'testnet.rvn.rocks'; // 'rvn4lyfe.com';
  static final int defaultPort = 50002; // 50003;

  static Map<String, Setting> get defaults => {
        SettingName.Electrum_Domain0:
            Setting(name: SettingName.Electrum_Domain0, value: defaultUrl),
        SettingName.Electrum_Port0:
            Setting(name: SettingName.Electrum_Port0, value: defaultPort),
        SettingName.Electrum_Domain1:
            Setting(name: SettingName.Electrum_Domain1, value: defaultUrl),
        SettingName.Electrum_Port1:
            Setting(name: SettingName.Electrum_Port1, value: defaultPort),
        SettingName.Electrum_Domain2:
            Setting(name: SettingName.Electrum_Domain2, value: defaultUrl),
        SettingName.Electrum_Port2:
            Setting(name: SettingName.Electrum_Port2, value: defaultPort),
        SettingName.Electrum_DomainTest:
            Setting(name: SettingName.Electrum_DomainTest, value: defaultUrl),
        SettingName.Electrum_PortTest:
            Setting(name: SettingName.Electrum_PortTest, value: defaultPort),
        SettingName.Electrum_Net:
            Setting(name: SettingName.Electrum_Net, value: Net.Test),
        SettingName.User_Name:
            Setting(name: SettingName.User_Name, value: null),
        SettingName.Send_Immediate:
            Setting(name: SettingName.Send_Immediate, value: false),
        SettingName.Account_Current:
            Setting(name: SettingName.Account_Current, value: '0'),
        SettingName.Account_Preferred:
            Setting(name: SettingName.Account_Preferred, value: '0'),
      }.map(
          (settingName, setting) => MapEntry(settingName.enumString, setting));

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
