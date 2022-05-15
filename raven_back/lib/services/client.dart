import 'dart:async';
import 'dart:io';

import 'package:raven_back/streams/client.dart';
import 'package:raven_back/streams/wallet.dart';
import 'package:raven_back/utilities/lock.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

/// client creation, logic, and settings.s
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();
  final _clientLock = ReaderWriterLock();
  RavenElectrumClient? ravenElectrumClient;

  Future<RavenElectrumClient> get client async {
    var x = ravenElectrumClient;
    if (x == null) {
      await createClient();
    }
    return ravenElectrumClient!;
  }

  /// move to object - I cannot see an easy way to move this to the client
  /// actually because we recreate a new client rather that tell the existing
  /// to reconnect...
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
      await createClient();
      // if we error this time, fail
      x = await callback();
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

  bool get connectionStatus => ravenElectrumClient != null ? true : false;

  /// we want exclusive access to the creation of the client so that we
  /// don't create many connections to the electrum server all at once.
  Future<void> createClient() async {
    await _clientLock.writeFuture(() async {
      streams.client.connected.add(ConnectionStatus.connecting);
      var newRavenClient = await _generateClient();
      if (newRavenClient != null) {
        ravenElectrumClient = newRavenClient;
        streams.client.connected.add(ConnectionStatus.connected);
      }
    });
  }

  Future<RavenElectrumClient?> _generateClient({
    String projectName = 'MTWallet',
    String buildVersion = '0.1',
  }) async {
    try {
      return await RavenElectrumClient.connect(
        res.settings.mainnet ? electrumDomain : electrumDomainTest,
        port: res.settings.mainnet ? electrumPort : electrumPortTest,
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
    /// this is not a user action - do not show activity
    streams.client.busy.add(true);
    streams.client.activity.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: 'Downloading your transactions...'));
    final addresses = res.addresses.toList();
    var existing = false;
    for (var address in addresses) {
      await onlySubscribeAddressUnspent(address);
      existing = true;
    }
    for (var address in addresses) {
      await onlySubscribeAddressHistory(address);
    }
    if (existing) {
      unawaited(services.download.history.allDoneProcess());
      for (var address in addresses) {
        if (address.wallet is LeaderWallet) {
          if (address.vouts.isNotEmpty) {
            services.wallet.leader
                .updateCounts(address, address.wallet as LeaderWallet);
          } else {
            services.wallet.leader
                .updateCache(address, address.wallet as LeaderWallet);
          }
        }
      }
    }
    streams.client.busy.add(false);
    streams.client.activity.add(ActivityMessage(active: false));
    return true;
  }

  bool toAllAssets() {
    for (var asset in res.assets) {
      onlySubscribeAsset(asset);
    }
    return true;
  }

  Future<bool> toAddress(Address address) async {
    await onlySubscribeAddressUnspent(address);
    await onlySubscribeAddressHistory(address);
    return true;
  }

  bool toAsset(Asset asset) {
    onlySubscribeAsset(asset);
    return true;
  }

  Future onlySubscribeAddressUnspent(Address address) async {
    if (!subscriptionHandlesUnspent.keys.contains(address.id)) {
      subscriptionHandlesUnspent[address.id] =
          (await services.client.api.subscribeAddress(address))
              .listen((String? status) async {
        /// no guarantee this will run first, so we don't want the other
        /// one to run first can save the status and keep this one from
        /// running, so we'll just download unspents everytime.
        //if (status == null || address.status?.status != status) {
        print('PULLING UNSPENTS');
        await services.download.unspents.pull(
          scripthashes: [address.scripthash],
        );
        //}
      });
    }
  }

  Future onlySubscribeAddressHistory(Address address) async {
    if (!subscriptionHandlesHistory.keys.contains(address.id)) {
      subscriptionHandlesHistory[address.id] =
          (await services.client.api.subscribeAddress(address))
              .listen((String? status) async {
        if (status == null || address.status?.status != status) {
          print('PULLING HISTORY $status');

          /// Get histories, update leader counts and
          /// Get transactions in batch.
          await services.download.history.getTransactions(
            await services.download.history
                .getHistory(address, updateLeader: true),
          );

          /// Get dangling transactions
          await services.download.history.allDoneProcess();

          /// Save status update
          await res.statuses.save(Status(
              linkId: address.id,
              statusType: StatusType.address,
              status: status));

          /// Derive more addresses
          if (address.wallet is LeaderWallet) {
            streams.wallet.deriveAddress.add(DeriveLeaderAddress(
              leader: address.wallet! as LeaderWallet,
              exposure: address.exposure,
            ));
          }
        }
      });
    }
  }

  Future onlySubscribeForStatus(Address address) async {
    (await services.client.api.subscribeAddress(address))
        .listen((String? status) async {
      await res.statuses.save(Status(
          linkId: address.id, statusType: StatusType.address, status: status));
    });
    await services.client.api.unsubscribeAddress(address);
  }

  Future onlySubscribeForStatuses(List<Address> addresses) async {
    var subs = await services.client.api.subscribeAddresses(addresses);
    for (var ixSub in subs.enumeratedTuple()) {
      ixSub.item2.listen((String? status) async {
        await res.statuses.save(Status(
            linkId: addresses[ixSub.item1].id,
            statusType: StatusType.address,
            status: status));
      });
    }
    await services.client.api.unsubscribeAddresses(addresses);
  }

  Future onlySubscribeAsset(Asset asset) async {
    if (!subscriptionHandlesAsset.keys.contains(asset.symbol)) {
      subscriptionHandlesAsset[asset.symbol] =
          (await services.client.api.subscribeAsset(asset))
              .listen((String? status) {
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
  Future<Stream<BlockHeader>> subscribeHeaders() async => await services.client
      .scope(() async => (await services.client.client).subscribeHeaders());

  Future<Stream<String?>> subscribeAsset(Asset asset) async =>
      await services.client.scope(() async =>
          (await (await services.client.client).subscribeAsset(asset.symbol)));

  Future<Stream<String?>> subscribeAddress(Address address) async =>
      await services.client.scope(() async =>
          (await (await services.client.client)
              .subscribeScripthash(address.scripthash)));

  Future<bool> unsubscribeAddress(Address address) async =>
      await services.client.scope(() async =>
          (await (await services.client.client)
              .unsubscribeScripthash(address.scripthash)));

  Future<List<Stream<String?>>> subscribeAddresses(
    List<Address> addresses,
  ) async =>
      await services.client.scope(() async =>
          (await (await services.client.client)
              .subscribeScripthashes(addresses.map((a) => a.scripthash))));

  Future<void> unsubscribeAddresses(List<Address> addresses) async =>
      await services.client.scope(() async =>
          await (await services.client.client)
              .unsubscribeScripthashes(addresses.map((a) => a.scripthash)));

  Future<List<List<ScripthashUnspent>>> getUnspents(
    Iterable<String> scripthashes,
  ) async =>
      await services.client.scope(() async =>
          await (await services.client.client).getUnspents(scripthashes));

  Future<List<List<ScripthashUnspent>>> getAssetUnspents(
    Iterable<String> scripthashes,
  ) async =>
      await services.client.scope(() async =>
          await (await services.client.client).getAssetUnspents(scripthashes));

  Future<List<ScripthashHistory>> getHistory(Address address) async =>
      await services.client.scope(() async =>
          await (await services.client.client).getHistory(address.scripthash));

  Future<List<List<ScripthashHistory>>> getHistories(
    List<Address> addresses,
  ) async =>
      await services.client.scope(() async =>
          await (await services.client.client)
              .getHistories(addresses.map((Address a) => a.scripthash)));

  Future<Tx> getTransaction(String transactionId) async =>
      await services.client.scope(() async =>
          await (await services.client.client).getTransaction(transactionId));

  Future<List<Tx>> getTransactions(Iterable<String> transactionIds) async =>
      await services.client.scope(() async =>
          await (await services.client.client).getTransactions(transactionIds));

  Future<String> sendTransaction(String rawTx) async =>
      await services.client.scope(() async =>
          await (await services.client.client).broadcastTransaction(rawTx));

  Future<AssetMeta?> getMeta(String symbol) async => await services.client
      .scope(() async => await (await services.client.client).getMeta(symbol));

  Future<String> getOwner(String symbol) async => await services.client.scope(
      () async => (await (await services.client.client)
              .getAddresses(symbol.endsWith('!') ? symbol : symbol + '!'))!
          .owner);

  Future<dynamic> ping() async => await services.client
      .scope(() async => await (await services.client.client).ping());

  /// we should instead just be able to send an empty string and make one call
  /// this returns too much data to be useful. we don't use this anymore.
  Future<Iterable<dynamic>> getAllAssetNames() async => [
        for (var char in 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split(''))
          await services.client.scope(() async =>
              await (await services.client.client).getAssetsByPrefix(char))
      ].expand((i) => i);

  Future<Iterable<dynamic>> getAssetNames(
          String prefix) async =>
      prefix.length >= 3
          ? await services.client.scope(() async =>
              await (await services.client.client).getAssetsByPrefix(prefix))
          : [];
}
