import 'dart:io';

import 'package:tuple/tuple.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class ClientService {
  static const Map<int, Tuple2<SettingName, SettingName>>
      electrumConnectionOptions = {
    0: Tuple2(SettingName.Electrum_Domain1, SettingName.Electrum_Port1),
    1: Tuple2(SettingName.Electrum_Domain2, SettingName.Electrum_Port2),
    2: Tuple2(SettingName.Electrum_Domain3, SettingName.Electrum_Port3),
  };

  int electrumSettingsChoice = 0;

  SettingName get chosenDomainSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item1;

  SettingName get chosenPortSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item2;

  String get chosenDomain =>
      settings.primaryIndex.getOne(chosenDomainSetting)!.value;

  int get chosenPort => settings.primaryIndex.getOne(chosenPortSetting)!.value;

  Future<RavenElectrumClient?> createClient() async {
    try {
      await RavenElectrumClient.connect(
        chosenDomain,
        port: chosenPort,
        connectionTimeout: connectionTimeout,
      );
    } on SocketException catch (_) {
      print(_);
      return null;
    }
  }

  void cycleNextElectrumConnectionOption() {
    electrumSettingsChoice =
        (electrumSettingsChoice + 1) % electrumConnectionOptions.length;
  }
}
