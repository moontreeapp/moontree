import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';

import 'package:ravencoin_back/extensions/object.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:ravencoin_back/version.dart';

import 'package:ravencoin_wallet/ravencoin_wallet.dart' show NetworkType;

part 'setting.keys.dart';

class SettingProclaim extends Proclaim<_SettingNameKey, Setting> {
  SettingProclaim() : super(_SettingNameKey());

  static final Net defaultNet = Net.Main;
  static final String defaultUrl = 'moontree.com';
  static final int defaultPort = defaultNet == Net.Test ? 50012 : 50002;

  /// port map
  //50001 - mainnet tcp
  //50002 - mainnet ssl
  //50011 - testnet tcp
  //50012 - testnet ssl

  static Map<String, Setting> get defaults => {
        SettingName.Version_Database:
            Setting(name: SettingName.Version_Database, value: 1),
        SettingName.Login_Attempts:
            Setting(name: SettingName.Login_Attempts, value: <DateTime>[]),
        SettingName.Electrum_Net:
            Setting(name: SettingName.Electrum_Net, value: defaultNet),
        SettingName.Electrum_Domain:
            Setting(name: SettingName.Electrum_Domain, value: defaultUrl),
        SettingName.Electrum_Port:
            Setting(name: SettingName.Electrum_Port, value: defaultPort),
        SettingName.Auth_Method: Setting(
            name: SettingName.Auth_Method, value: AuthMethod.nativeSecurity),
        SettingName.Blockchain:
            Setting(name: SettingName.Blockchain, value: Chain.ravencoin),
        SettingName.Wallet_Current:
            Setting(name: SettingName.Wallet_Current, value: '0'),
        SettingName.Wallet_Preferred:
            Setting(name: SettingName.Wallet_Preferred, value: '0'),
        SettingName.User_Name:
            Setting(name: SettingName.User_Name, value: null),
        SettingName.Send_Immediate:
            Setting(name: SettingName.Send_Immediate, value: false),
        SettingName.Version_Current:
            Setting(name: SettingName.Send_Immediate, value: null),
        SettingName.Version_Previous:
            Setting(name: SettingName.Send_Immediate, value: null),
        SettingName.Mode_Dev: Setting(name: SettingName.Mode_Dev, value: false),
      }.map((settingName, setting) => MapEntry(settingName.name, setting));

  /// should this be in the database or should it be a constant somewhere?
  //int get appVersion =>
  //    primaryIndex.getOne(SettingName.App_Version)!.value;

  int get databaseVersion =>
      primaryIndex.getOne(SettingName.Version_Database)!.value;

  String get preferredWalletId =>
      primaryIndex.getOne(SettingName.Wallet_Preferred)!.value;

  String get currentWalletId =>
      primaryIndex.getOne(SettingName.Wallet_Current)!.value;

  String? get localPath => primaryIndex.getOne(SettingName.Local_Path)?.value;

  String get domainPort =>
      '${primaryIndex.getOne(SettingName.Electrum_Domain)?.value}:${primaryIndex.getOne(SettingName.Electrum_Port)?.value}';

  String get defaultDomainPort => '$defaultUrl:$defaultPort';

  Future restoreDomainPort() async => await saveAll([
        Setting(name: SettingName.Electrum_Domain, value: defaultUrl),
        Setting(name: SettingName.Electrum_Port, value: defaultPort),
      ]);

  Future savePreferredWalletId(String walletId) async =>
      await save(Setting(name: SettingName.Wallet_Preferred, value: walletId));

  Future setCurrentWalletId([String? walletId]) async => await save(Setting(
      name: SettingName.Wallet_Current, value: walletId ?? preferredWalletId));

  Net get net => primaryIndex.getOne(SettingName.Electrum_Net)!.value;

  bool get mainnet =>
      primaryIndex.getOne(SettingName.Electrum_Net)!.value == Net.Main;

  NetworkType get network => networks[net]!;

  String get netName => net.name;

  List get loginAttempts =>
      primaryIndex.getOne(SettingName.Login_Attempts)!.value;

  Future saveLoginAttempts(List attempts) async =>
      await save(Setting(name: SettingName.Login_Attempts, value: attempts));

  Future incrementLoginAttempts() async =>
      await saveLoginAttempts(loginAttempts + <DateTime>[DateTime.now()]);

  Future resetLoginAttempts() async => await saveLoginAttempts([]);

  Chain get chain => primaryIndex.getOne(SettingName.Blockchain)!.value;

  Future setBlockchain({
    Chain chain = Chain.ravencoin,
    Net net = Net.Main,
  }) async {
    await saveAll([
      Setting(name: SettingName.Electrum_Net, value: net),
      Setting(name: SettingName.Blockchain, value: chain),
    ]);

    /// triggers should be set to change the domain:port by chain:net
    /// for now we'll put it here:
    await saveAll([
      Setting(
          name: SettingName.Electrum_Port,
          value: net == Net.Test ? 50012 : 50002),
      Setting(
          name: SettingName.Electrum_Domain,
          value: chain == Chain.ravencoin
              ? defaultUrl
              : defaultUrl /*electrum for evrmore???*/),
    ]);
  }

  AuthMethod? get authMethod =>
      primaryIndex.getOne(SettingName.Auth_Method)?.value;

  bool get authMethodIsNativeSecurity =>
      primaryIndex.getOne(SettingName.Auth_Method)!.value ==
      AuthMethod.nativeSecurity;

  bool get developerMode => primaryIndex.getOne(SettingName.Mode_Dev)!.value;

  Future toggleDevMode([bool? turnOn]) async => await save(
        Setting(name: SettingName.Mode_Dev, value: turnOn ?? !developerMode),
      );
}
