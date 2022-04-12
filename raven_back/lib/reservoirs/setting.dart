import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/records/records.dart';

import 'package:ravencoin_wallet/ravencoin_wallet.dart' show NetworkType;

part 'setting.keys.dart';

class SettingReservoir extends Reservoir<_SettingNameKey, Setting> {
  SettingReservoir() : super(_SettingNameKey());

  /// some other options for testing before we get our own electrum server up:
  // mainnet electrum3.rvn.rocks
  // testnet rvn4lyfe.com:50003
  // 143.198.142.78:50002
  // mjQSgeVh5ZHfwGzBkiQcpr119Wh6QMyQ3b

  //static final String defaultUrl = 'testnet.rvn.rocks'; // 'rvn4lyfe.com';
  //static final int defaultPort = 50002; // 50003;

  static final String defaultUrl = '143.198.142.78';
  static final int defaultPort = 50002;

  static Map<String, Setting> get defaults => {
        SettingName.Electrum_Net:
            Setting(name: SettingName.Electrum_Net, value: Net.Test),
        SettingName.Electrum_Domain:
            Setting(name: SettingName.Electrum_Domain, value: defaultUrl),
        SettingName.Electrum_Port:
            Setting(name: SettingName.Electrum_Port, value: defaultPort),
        SettingName.Electrum_DomainTest:
            Setting(name: SettingName.Electrum_DomainTest, value: defaultUrl),
        SettingName.Electrum_PortTest:
            Setting(name: SettingName.Electrum_PortTest, value: defaultPort),
        SettingName.Wallet_Current:
            Setting(name: SettingName.Wallet_Current, value: '0'),
        SettingName.Wallet_Preferred:
            Setting(name: SettingName.Wallet_Preferred, value: '0'),
        SettingName.User_Name:
            Setting(name: SettingName.User_Name, value: null),
        SettingName.Send_Immediate:
            Setting(name: SettingName.Send_Immediate, value: false),
      }.map(
          (settingName, setting) => MapEntry(settingName.enumString, setting));

  String get preferredWalletId =>
      primaryIndex.getOne(SettingName.Wallet_Preferred)!.value;

  String get currentWalletId =>
      primaryIndex.getOne(SettingName.Wallet_Current)!.value;

  String? get localPath => primaryIndex.getOne(SettingName.Local_Path)?.value;

  Future savePreferredWalletId(String walletId) async =>
      await save(Setting(name: SettingName.Wallet_Preferred, value: walletId));

  Future setCurrentWalletId([String? walletId]) async => await save(Setting(
      name: SettingName.Wallet_Current, value: walletId ?? preferredWalletId));

  Net get net => primaryIndex.getOne(SettingName.Electrum_Net)!.value;
  bool get mainnet =>
      primaryIndex.getOne(SettingName.Electrum_Net)!.value == Net.Main;
  NetworkType get network => networks[net]!;
  String get netName => net.enumString;
}
