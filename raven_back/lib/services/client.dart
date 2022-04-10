import 'dart:async';
import 'dart:io';

import 'package:raven_back/streams/wallet.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// client creation, logic, and settings.
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();

  RavenElectrumClient? get client => streams.client.client.value;

  String get electrumDomain =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_Domain)!.value;

  int get electrumPort =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value;

  String get electrumDomainTest =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_DomainTest)!.value;

  int get electrumPortTest =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_PortTest)!.value;

  String get currentDomain =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_Net)!.value ==
              Net.Main
          ? res.settings.primaryIndex.getOne(SettingName.Electrum_Domain)!.value
          : res.settings.primaryIndex
              .getOne(SettingName.Electrum_DomainTest)!
              .value;

  int get currentPort => res.settings.primaryIndex
              .getOne(SettingName.Electrum_Net)!
              .value ==
          Net.Main
      ? res.settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value
      : res.settings.primaryIndex.getOne(SettingName.Electrum_PortTest)!.value;

  bool get connectionStatus =>
      streams.client.client.stream.valueOrNull != null ? true : false;

  Future<RavenElectrumClient?> createClient(
      {String projectName = 'MTWallet', String buildVersion = '0.1'}) async {
    try {
      if (res.settings.primaryIndex.getOne(SettingName.Electrum_Net)?.value ==
          Net.Main) {
        return await RavenElectrumClient.connect(
          electrumDomain,
          port: electrumPort,
          clientName: '$projectName/$buildVersion',
          connectionTimeout: connectionTimeout,
        );
      }
      return await RavenElectrumClient.connect(
        electrumDomainTest,
        port: electrumPortTest,
        clientName: '$projectName/$buildVersion',
        connectionTimeout: connectionTimeout,
      );
    } on SocketException catch (_) {
      print(_);
    }
    return null;
  }

  Future saveElectrumAddress({
    required String domain,
    required int port,
  }) async =>
      res.settings.primaryIndex.getOne(SettingName.Electrum_Net)?.value ==
              Net.Main
          ? await res.settings.saveAll([
              Setting(name: SettingName.Electrum_Domain, value: domain),
              Setting(name: SettingName.Electrum_Port, value: port),
            ])
          : await res.settings.saveAll([
              Setting(name: SettingName.Electrum_DomainTest, value: domain),
              Setting(name: SettingName.Electrum_PortTest, value: port),
            ]);
}

/// managing our address subscriptions
class SubscribeService {
  final Map<String, StreamSubscription> subscriptionHandles = {};

  bool toAllAddresses() {
    var client = streams.client.client.value;
    print(
        'To all addresses called subscribe.to client==null: ${client == null}');
    if (client == null) {
      return false;
    }
    for (var address in res.addresses) {
      onlySubscribe(client, address);
    }
    return true;
  }

  bool to(Address address) {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    onlySubscribe(client, address);
    return true;
  }

  void onlySubscribe(RavenElectrumClient client, Address address) {
    if (!subscriptionHandles.keys.contains(address.id)) {
      subscriptionHandles[address.id] =
          client.subscribeScripthash(address.id).listen((String? status) async {
        if (status == null || address.status?.status != status) {
          await res.statuses.save(Status(
              linkId: address.id,
              statusType: StatusType.address,
              status: status));
          await services.download.unspents.pull(scripthashes: [address.id]);
          var allDone = await services.download.history.getHistories(address);
          if (allDone != null && !allDone && address.wallet is LeaderWallet) {
            streams.wallet.deriveAddress.add(DeriveLeaderAddress(
              leader: address.wallet! as LeaderWallet,
              exposure: address.exposure,
            ));
          }
        }
      });
    }
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
    return await streams.client.client.value!.broadcastTransaction(rawTx);
  }

  Future<Tx> getTransaction(String transactionId) async =>
      await streams.client.client.value!.getTransaction(transactionId);

  /// we should instead just be able to send an empty string and make one call
  /// this returns too much data to be useful. we don't use this anymore.
  Future<Iterable<dynamic>> getAllAssetNames() async => [
        for (var char in 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split(''))
          await streams.client.client.value!.getAssetsByPrefix(char)
      ].expand((i) => i);

  Future<Iterable<dynamic>> getAssetNames(String prefix) async =>
      prefix.length >= 3
          ? await streams.client.client.value?.getAssetsByPrefix(prefix) ?? []
          : [];
}
