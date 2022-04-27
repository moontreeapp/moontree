import 'dart:async';
import 'dart:io';

import 'package:raven_back/streams/wallet.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// client creation, logic, and settings.s
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();

  RavenElectrumClient? get client => streams.client.client.value;
  RavenElectrumClient? get useClient => streams.client.client.value;

  /// if we want to talk to electrum safely, this will try to talk,
  /// if communication fails it will reconnect and try again.
  /// for example:
  ///   await services.client.scope(() async {
  ///     print('erroring if client is null is desirable in this scope');
  ///     return await services.client.client!.getRelayFee();
  ///   }));
  Future<T> scope<T>(Future<T> Function() callback) async {
    var x;
    try {
      x = await callback();
    } catch (e) {
      // reconnect on any error, not just server disconnected } on StateError {
      streams.client.client.add(null);
      while (streams.client.client.value == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      /// making this two layers deep because we got an error here too...
      /// saw the error gain in catch, so ... we need to either make it recursive, or something.
      try {
        x = await callback();
      } catch (e) {
        // reconnect on any error, not just server disconnected } on StateError {
        streams.client.client.add(null);
        while (streams.client.client.value == null) {
          await Future.delayed(Duration(milliseconds: 100));
        }
        x = await callback();
      }
    }
    return x;
  }

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

  Future<RavenElectrumClient?> createClient({
    String projectName = 'MTWallet',
    String buildVersion = '0.1',
  }) async {
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
  final Map<String, StreamSubscription> subscriptionHandlesUnspent = {};
  final Map<String, StreamSubscription> subscriptionHandlesHistory = {};
  final Map<String, StreamSubscription> subscriptionHandlesAsset = {};

  Future<bool> toAllAddresses() async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    streams.client.busy.add(true);
    final addresses = res.addresses.toList();
    var existing = false;
    for (var address in addresses) {
      onlySubscribeAddressUnspent(client, address);
      existing = true;
    }
    for (var address in addresses) {
      onlySubscribeAddressHistory(client, address);
    }
    if (existing) {
      unawaited(services.download.history.allDoneProcess(client));
      for (var address in addresses) {
        if (address.wallet is LeaderWallet && address.vouts.isNotEmpty) {
          services.wallet.leader
              .updateCounts(address, address.wallet as LeaderWallet);
        } else {
          services.wallet.leader
              .updateCache(address, address.wallet as LeaderWallet);
        }
      }
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
    //streams.client.busy.add(true);
    onlySubscribeAddressUnspent(client, address);
    onlySubscribeAddressHistory(client, address);
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

  void onlySubscribeAddressUnspent(
      RavenElectrumClient client, Address address) {
    if (!subscriptionHandlesUnspent.keys.contains(address.id)) {
      subscriptionHandlesUnspent[address.id] =
          client.subscribeScripthash(address.id).listen((String? status) async {
        await services.download.unspents.pull(scripthashes: [address.id]);
      });
    }
  }

  void onlySubscribeAddressHistory(
      RavenElectrumClient client, Address address) {
    if (!subscriptionHandlesHistory.keys.contains(address.id)) {
      subscriptionHandlesHistory[address.id] =
          client.subscribeScripthash(address.id).listen((String? status) async {
        if (status == null || address.status?.status != status) {
          var allDone =
              await services.download.history.getHistories(address, status);
          //// why not just do this here?
          //await res.statuses.save(Status(
          //    linkId: address.id,
          //    statusType: StatusType.address,
          //    status: status));
          if (allDone == false && address.wallet is LeaderWallet) {
            streams.wallet.deriveAddress.add(DeriveLeaderAddress(
              leader: address.wallet! as LeaderWallet,
              exposure: address.exposure,
            ));
          }
        } else {
          await services.download.history.addAddressToSkipHistory(address);
          if (address.wallet is LeaderWallet) {
            services.wallet.leader
                .updateCounts(address, address.wallet as LeaderWallet);
          }
        }
      });
    }
  }

  void onlySubscribeAsset(RavenElectrumClient client, Asset asset) {
    if (!subscriptionHandlesAsset.keys.contains(asset.symbol)) {
      subscriptionHandlesAsset[asset.symbol] =
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
    subscriptionHandlesUnspent.remove(addressId)?.cancel();
    subscriptionHandlesHistory.remove(addressId)?.cancel();
  }

  void unsubscribeAsset(String asset) {
    subscriptionHandlesAsset.remove(asset)?.cancel();
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
