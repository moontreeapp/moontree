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

  String get currentDomain => res.settings.mainnet
      ? res.settings.primaryIndex.getOne(SettingName.Electrum_Domain)!.value
      : res.settings.primaryIndex
          .getOne(SettingName.Electrum_DomainTest)!
          .value;

  int get currentPort => res.settings.mainnet
      ? res.settings.primaryIndex.getOne(SettingName.Electrum_Port)!.value
      : res.settings.primaryIndex.getOne(SettingName.Electrum_PortTest)!.value;

  bool get connectionStatus =>
      streams.client.client.stream.valueOrNull != null ? true : false;

  Future<RavenElectrumClient?> createClient(
      {String projectName = 'MTWallet', String buildVersion = '0.1'}) async {
    try {
      if (res.settings.mainnet) {
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
      res.settings.mainnet
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
    if (client == null) {
      return false;
    }
    var existing = false;
    for (var address in res.addresses) {
      onlySubscribeAddress(client, address);
      existing = true;
    }
    if (existing) {
      services.download.history.allDoneProcess(client);
    }
    return true;
  }

  bool toAllAssets() {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    for (var asset in res.assets) {
      onlySubscribeAsset(client, asset);
    }
    return true;
  }

  bool toAddress(Address address) {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    onlySubscribeAddress(client, address);
    return true;
  }

  bool toAsset(Asset asset) {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    onlySubscribeAsset(client, asset);
    return true;
  }

  void onlySubscribeAddress(RavenElectrumClient client, Address address) {
    if (!subscriptionHandles.keys.contains(address.id)) {
      subscriptionHandles[address.id] =
          client.subscribeScripthash(address.id).listen((String? status) async {
        print('Received call back for subscription to ${address.address}');
        await services.download.unspents.pull(scripthashes: [address.id]);
        if (status == null || address.status?.status != status) {
          var allDone = await services.download.history.getHistories(address);
          await res.statuses.save(Status(
              linkId: address.id,
              statusType: StatusType.address,
              status: status));
          if (allDone != null && !allDone && address.wallet is LeaderWallet) {
            streams.wallet.deriveAddress.add(DeriveLeaderAddress(
              leader: address.wallet! as LeaderWallet,
              exposure: address.exposure,
            ));
          } else {
            // why are we doing this here? happens in get history...
            await services.balance.recalculateAllBalances();
          }
        } else {
          // why does this need to happen again?
          await services.download.history.addAddressToSkipHistory(address);
        }

        /// happens in get history...
        //streams.wallet.scripthashCallback.add(null);
      });
    }
  }

  void onlySubscribeAsset(RavenElectrumClient client, Asset asset) {
    if (!subscriptionHandles.keys.contains(asset.symbol)) {
      subscriptionHandles[asset.symbol] =
          client.subscribeAsset(asset.symbol).listen((String? status) {
        if (asset.status?.status != status) {
          res.statuses.save(Status(
              linkId: asset.symbol,
              statusType: StatusType.asset,
              status: status));
          //Handles saving the asset meta & the security
          services.download.asset.get(asset.symbol);
        }
      });
    }
  }

  void unsubscribeAddress(String addressId) {
    subscriptionHandles.remove(addressId)?.cancel();
  }

  void unsubscribeAsset(String asset) {
    subscriptionHandles.remove(asset)?.cancel();
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
