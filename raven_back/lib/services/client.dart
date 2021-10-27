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

  RavenElectrumClient? mostRecentRavenClient;

  Future<RavenElectrumClient?> get clientOrNull async =>
      await subjects.client.last;

  int electrumSettingsChoice = 0;

  SettingName get chosenDomainSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item1;

  SettingName get chosenPortSetting =>
      electrumConnectionOptions[electrumSettingsChoice]!.item2;

  String get chosenDomain =>
      settings.primaryIndex.getOne(chosenDomainSetting)!.value;

  int get chosenPort => settings.primaryIndex.getOne(chosenPortSetting)!.value;

  String get preferredElectrumDomain =>
      settings.primaryIndex.getOne(SettingName.Electrum_Domain0)!.value;

  int get preferredElectrumPort =>
      settings.primaryIndex.getOne(SettingName.Electrum_Port0)!.value;

  String get firstBackupElectrumDomain =>
      settings.primaryIndex.getOne(SettingName.Electrum_Domain1)!.value;

  int get firstBackupElectrumPort =>
      settings.primaryIndex.getOne(SettingName.Electrum_Port1)!.value;

  String get secondBackupElectrumDomain =>
      settings.primaryIndex.getOne(SettingName.Electrum_Domain2)!.value;

  int get secondBackupElectrumPort =>
      settings.primaryIndex.getOne(SettingName.Electrum_Port2)!.value;

  bool get connectionStatus =>
      subjects.client.stream.valueOrNull != null ? true : false;

  Future<RavenElectrumClient?> createClient(
      {String projectName = 'MTWallet', String buildVersion = '0.1'}) async {
    try {
      return await RavenElectrumClient.connect(
        chosenDomain,
        port: chosenPort,
        clientName: '$projectName/$buildVersion',
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

  // todo: move
  Future<String> getOwner(String symbol) async => (await mostRecentRavenClient!
          .getAddresses(symbol.endsWith('!') ? symbol : symbol + '!'))!
      .owner;

  Future<String> sendTransaction(String rawTx) async {
    //print(mostRecentRavenClient);
    //print(await clientOrNull);
    //print(mostRecentRavenClient == await clientOrNull);
    return await mostRecentRavenClient!.broadcastTransaction(rawTx);
    //return await (await clientOrNull)!.broadcastTransaction(rawTx);
    //mqkt8ZNFySs4QtsxHp5PsAjLS85hJuDH6Y
  }
}
