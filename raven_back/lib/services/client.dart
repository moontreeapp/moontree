import 'dart:io';

import 'package:tuple/tuple.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class ClientService {
  static const Map<int, Tuple2<SettingName, SettingName>>
      electrumConnectionOptions = {
    0: Tuple2(SettingName.Electrum_Domain0, SettingName.Electrum_Port0),
    1: Tuple2(SettingName.Electrum_Domain1, SettingName.Electrum_Port1),
    2: Tuple2(SettingName.Electrum_Domain2, SettingName.Electrum_Port2),
  };

  int electrumSettingsChoice = 0;

  SettingName get chosenDomainSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item1;

  SettingName get chosenPortSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item2;

  String get chosenDomain =>
      settings.primaryIndex.getOne(chosenDomainSetting)!.value;

  int get chosenPort => settings.primaryIndex.getOne(chosenPortSetting)!.value;

  String get chosenDomainFirstBackup =>
      settings.primaryIndex.getOne(SettingName.Electrum_Domain1)!.value;

  int get chosenPortFirstBackup =>
      settings.primaryIndex.getOne(SettingName.Electrum_Port1)!.value;

  String get chosenDomainSecondBackup =>
      settings.primaryIndex.getOne(SettingName.Electrum_Domain2)!.value;

  int get chosenPortSecondBackup =>
      settings.primaryIndex.getOne(SettingName.Electrum_Port2)!.value;

  bool get connectionStatus =>
      ravenClientSubject.stream.valueOrNull != null ? true : false;

  Future<RavenElectrumClient?> createClient() async {
    try {
      return await RavenElectrumClient.connect(
        chosenDomain,
        port: chosenPort,
        connectionTimeout: connectionTimeout,
      );
    } on SocketException catch (_) {
      print(_);
    }
  }

  void cycleNextElectrumConnectionOption() {
    electrumSettingsChoice =
        (electrumSettingsChoice + 1) % electrumConnectionOptions.length;
  }

  Future saveElectrumAddresses(
      {required List<String> domains, required List<int> ports}) async {
    await settings.saveAll([
      Setting(name: SettingName.Electrum_Domain0, value: domains[0]),
      Setting(name: SettingName.Electrum_Port0, value: ports[0]),
      Setting(name: SettingName.Electrum_Domain1, value: domains[1]),
      Setting(name: SettingName.Electrum_Port1, value: ports[1]),
      Setting(name: SettingName.Electrum_Domain2, value: domains[2]),
      Setting(name: SettingName.Electrum_Port2, value: ports[2]),
    ]);
  }
}
