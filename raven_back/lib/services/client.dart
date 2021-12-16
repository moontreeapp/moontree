import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_back/raven_back.dart';

/// client creation, logic, and settings.
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();

  static const Map<int, Tuple2<SettingName, SettingName>>
      electrumConnectionOptions = {
    0: Tuple2(SettingName.Electrum_Domain0, SettingName.Electrum_Port0),
    1: Tuple2(SettingName.Electrum_Domain1, SettingName.Electrum_Port1),
    2: Tuple2(SettingName.Electrum_Domain2, SettingName.Electrum_Port2),
  };

  RavenElectrumClient? get client => streams.client.client.value;

  ClientService? mostRecentAppStatus;

  Future<RavenElectrumClient?> get clientOrNull async =>
      await streams.client.client.last;

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

  String get testElectrumDomain =>
      settings.primaryIndex.getOne(SettingName.Electrum_DomainTest)!.value;

  int get testElectrumPort =>
      settings.primaryIndex.getOne(SettingName.Electrum_PortTest)!.value;

  bool get connectionStatus =>
      streams.client.client.stream.valueOrNull != null ? true : false;

  Future<RavenElectrumClient?> createClient(
      {String projectName = 'MTWallet', String buildVersion = '0.1'}) async {
    try {
      if (settings.primaryIndex.getOne(SettingName.Electrum_Net)?.value ==
          Net.Test) {
        return await RavenElectrumClient.connect(
          testElectrumDomain,
          port: testElectrumPort,
          clientName: '$projectName/$buildVersion',
          connectionTimeout: connectionTimeout,
        );
      }
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
      Setting(name: SettingName.Electrum_DomainTest, value: domains[3]),
      Setting(name: SettingName.Electrum_PortTest, value: ports[3]),
    ]);
  }
}

/// managing our address subscriptions
class SubscribeService {
  final Map<String, StreamSubscription> subscriptionHandles = {};
  final PublishSubject<Address> addressesNeedingUpdate = PublishSubject();

  void toExistingAddresses([RavenElectrumClient? client]) {
    for (var address in addresses) {
      if (address.account!.net ==
          settings.primaryIndex.getOne(SettingName.Electrum_Net)!.value) {
        if (!subscriptionHandles.keys.contains(address.addressId)) {
          // getting a client error here during startup (before client instanteated)
          // we shouldn't trigger thais until we have a client up.
          // or we should backlog it.
          to(client ?? streams.client.client.value!, address);
        }
      }
    }
  }

  void to(RavenElectrumClient client, Address address) {
    // we get a status back as soon as we subscribe... so we don't need to do it here.
    //addressesNeedingUpdate.sink.add(address);
    var stream = client.subscribeScripthash(address.addressId);
    subscriptionHandles[address.addressId] = stream.listen((status) {
      addressesNeedingUpdate.sink.add(address);
    });
  }

  void unsubscribe(String addressId) {
    if (subscriptionHandles.keys.contains(addressId)) {
      subscriptionHandles[addressId]!.cancel();
      subscriptionHandles.remove(addressId);
    }
  }
}

/// calls to the electrum server
class ApiService {
  Future<String> getOwner(String symbol) async =>
      (await streams.client.client.value!
              .getAddresses(symbol.endsWith('!') ? symbol : symbol + '!'))!
          .owner;

  Future<String> sendTransaction(String rawTx) async {
    //services.client.subscribe.subscribeToExistingAddresses();
    return await streams.client.client.value!.broadcastTransaction(rawTx);
  }

  Future<Tx> getTransaction(String txId) async =>
      await streams.client.client.value!.getTransaction(txId);

  /// we should instead just be able to send an empty string and make one call
  Future<Iterable<dynamic>> getAllAssetNames() async => [
        for (var char in 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split(''))
          await streams.client.client.value!.getAssetsByPrefix(char)
      ].expand((i) => i);

  Future<Iterable<dynamic>> getAssetNames(String prefix) async =>
      prefix.isNotEmpty
          ? await streams.client.client.value!.getAssetsByPrefix(prefix)
          : [];
}
