// ignore_for_file: omit_local_variable_types

import 'dart:async';
import 'dart:io';

import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/utilities/database.dart' as database;
import 'package:ravencoin_back/utilities/lock.dart';
import 'package:ravencoin_back/waiters/client.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

/// client creation, logic, and settings.s
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();
  final _clientLock = ReaderWriterLock();
  RavenElectrumClient? ravenElectrumClient;
  DateTime lastActiveTime = DateTime.now();
  static const Duration inactiveGracePeriod = Duration(seconds: 10);

  StreamSubscription? periodicTimer;

  String get serverUrl =>
      '${services.client.currentDomain}:${services.client.currentPort}';

  Future<RavenElectrumClient> get client async {
    var x = ravenElectrumClient;
    if (x == null) {
      throw Exception('client not initialized');
      //await createClient();
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
    /// if we haven't had a call for 10 seconds, the client isn't busy
    lastActiveTime = DateTime.now();
    var x;
    try {
      x = await callback();
      //} catch (e) {
    } on StateError {
      //print('creatingClient because of StateError');
      ////print(e);
      //// reconnect on any error, not just server disconnected } on StateError {
      //await createClient();
      //// if we error this time, fail
      //x = await callback();
      x = null;
    }
    return x;
  }

  String get electrumDomain =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_domain)!.value;

  int get electrumPort =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_port)!.value;

  String get currentDomain =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_domain)!.value;

  int get currentPort =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_port)!.value;

  bool get connectionStatus => ravenElectrumClient != null ? true : false;

  Future<void> disconnect() async {
    streams.client.connected.add(ConnectionStatus.disconnected);
    ravenElectrumClient = null;
  }

  /// we want exclusive access to the creation of the client so that we
  /// don't create many connections to the electrum server all at once.
  Future<void> createClient() async {
    lastActiveTime = DateTime.now();
    await periodicTimer?.cancel();
    periodicTimer = Stream.periodic(inactiveGracePeriod).listen((_) async {
      print(DateTime.now().difference(lastActiveTime).inSeconds);
      if (streams.client.busy.value &&
          DateTime.now().difference(lastActiveTime).inSeconds >=
              inactiveGracePeriod.inSeconds) {
        streams.client.busy.add(false);
      }
    });
    await _clientLock.writeFuture(() async {
      streams.client.connected.add(ConnectionStatus.connecting);
      Future<void> genClient() async {
        var newRavenClient = await _generateClient();
        if (newRavenClient != null) {
          ravenElectrumClient = newRavenClient;
          streams.client.connected.add(ConnectionStatus.connected);
        } else {
          if (pros.settings.domainPort != pros.settings.defaultDomainPort) {
            streams.app.snack.add(Snack(
                message:
                    'Unable to connect to ${pros.settings.domainPort}, restoring defaults...'));
            await pros.settings.restoreDomainPort();
            await genClient();
          }
        }
      }

      await genClient();
    });
  }

  Future<RavenElectrumClient?> _generateClient({
    String projectName = 'moontree',
    String? projectVersion,
  }) async {
    try {
      return await RavenElectrumClient.connect(
        electrumDomain,
        port: electrumPort,
        clientName: projectName,
        clientVersion: projectVersion ?? (services.version.current ?? 'v1.0'),
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
      await pros.settings.saveAll([
        Setting(name: SettingName.electrum_domain, value: domain),
        Setting(name: SettingName.electrum_port, value: port),
      ]);

  Future switchNetworks({required Chain chain, required Net net}) async {
    await pros.settings.setBlockchain(chain: chain, net: net);
    await resetMemoryAndConnection();
  }

  Future<void> resetMemoryAndConnection({
    bool keepTx = false,
    bool keepBalances = false,
    bool keepAddresses = false,
  }) async {
    /// notice that we remove all our database here entirely.
    /// this is the simplest way to handle it (changing blockchains, this is also it's own feature).
    /// it might be ideal to keep the transactions, vout, unspents, vins, addresses, etc.
    /// but we're not ging to because we'd have to segment all of them by network.
    /// this is something we could do later if we want.
    await services.client.disconnect();

    database.resetInMemoryState();
    if (!keepTx) {
      await database.eraseTransactionData(quick: true);
    }
    await database.eraseUnspentData(quick: true, keepBalances: keepBalances);
    if (!keepAddresses) {
      await database.eraseAddressData(quick: true);
    }
    if (keepBalances) {
      services.download.overrideGettingStarted = true;
    }

    /// make a new client to connect to the new network
    await services.client.createClient();

    /// start derivation process
    if (!keepAddresses) {
      final currentWallet = services.wallet.currentWallet;
      if (currentWallet is LeaderWallet) {
        await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
      } else {
        // trigger single derive?
      }

      /// we could do this when we nav to it. (front services switchWallet)
      //for (var wallet in pros.wallets.records) {
      //  if (wallet != currentWallet) {
      //    await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
      //  }
      //}
    }

    // subscribe
    //await waiters.block.subscribe();
    //await services.client.subscribe.toAllAddresses();

    /// update the UI
    streams.app.wallet.refresh.add(true);
  }
}

/// managing our address subscriptions
class SubscribeService {
  // {wallet: {address: subscription}}
  final Map<String, Map<String, StreamSubscription>>
      subscriptionHandlesAddress = {};
  final Map<String, StreamSubscription> subscriptionHandlesAsset = {};
  bool startupProcessRunning = false;

  Future<bool> toAllAddresses() async {
    /// this is not a user action - do not show activity
    startupProcessRunning = true;
    streams.client.busy.add(true);
    streams.client.activity.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: 'Downloading your transactions...'));

    /// if we kill the import process we can end up having addresses unassociated with a wallet so remove them first.
    final walletIds = pros.wallets.records.map((e) => e.id);
    await pros.addresses.removeAll(
        pros.addresses.records.where((a) => !walletIds.contains(a.walletId)));

    // we have to update these counts incase the user logins before the processes is over
    final addresses = pros.addresses.toSet();
    final currentAddresses = (pros.wallets.primaryIndex
                .getOne(pros.settings.currentWalletId)
                ?.addresses ??
            [])
        .toSet();
    final otherAddresses = addresses.difference(currentAddresses);
    for (var address in currentAddresses) {
      await subscribeAddress(address);
    }
    for (var address in otherAddresses) {
      await subscribeAddress(address);
    }
    //if (addresses.isNotEmpty) {
    //  await services.download.history.allDoneProcess();
    //}
    return true;
  }

  bool toAllAssets() {
    for (var asset in pros.assets) {
      subscribeAsset(asset);
    }
    return true;
  }

  Future<bool> toAddress(Address address) async {
    await subscribeAddress(address);
    return true;
  }

  bool toAsset(Asset asset) {
    subscribeAsset(asset);
    return true;
  }

  Future maybeDerive(Address address) async {
    final wallet = address.wallet;
    if (wallet is LeaderWallet) {
      if (!services.wallet.leader.gapSatisfied(wallet, address.exposure)) {
        await services.wallet.leader.handleDeriveAddress(
          leader: wallet,
          exposure: address.exposure,
        );
      } else {
        // remember that we don't have to check for this wallet.
      }
    }
  }

  Future pullUnspents(Address address) async {
    await services.download.unspents.pull(
      scripthashes: {address.scripthash},
      wallet: address.wallet!,
      getTransactions: true,
      chain: pros.settings.chain,
      net: pros.settings.net,
    );
  }

  void queueHistoryDownload(Address address) => null;
  //services.download.queue.update(address: address);

  Future saveStatusUpdate(Address address, String? status) async =>
      await pros.statuses.save(Status(
        linkId: address.id,
        statusType: StatusType.address,
        status: status,
      ));

  Future subscribeAddress(Address address) async {
    if (!subscriptionHandlesAddress.keys.contains(address.walletId)) {
      subscriptionHandlesAddress[address.walletId] = {};
    }
    if (!subscriptionHandlesAddress[address.walletId]!
        .keys
        .contains(address.id)) {
      subscriptionHandlesAddress[address.walletId]![address.id] =
          (await services.client.api.subscribeAddress(address))
              .listen((String? status) async {
        if (!streams.client.busy.value) {
          streams.client.busy.add(true);
        }
        final addressStatus = address.status;
        await saveStatusUpdate(address, status);

        /// process
        if (addressStatus?.status == null && status == null) {
          broadcastActivity(address: address.address, status: 'empty');
          await maybeDerive(address);
        } else if (addressStatus?.status == null && status != null) {
          broadcastActivity(address: address.address, status: 'used');
          await maybeDerive(address);
          await pullUnspents(address);
        } else if (addressStatus?.status != status) {
          broadcastActivity(
              address: address.address, status: 'new transaction for');
          await pullUnspents(address);
        } else if (addressStatus?.status == status) {
          await pullUnspents(address); // just incase we don't have them...
          // do nothing
        }
        final wallet = address.wallet!;

        /// end of process
        if (wallet is LeaderWallet &&
            services.wallet.leader.gapSatisfied(wallet) &&
            subscriptionHandlesAddress.containsKey(address.walletId) &&
            subscriptionHandlesAddress[address.walletId]!.keys.length ==
                wallet.addresses.length) {
          await services.balance
              .recalculateAllBalances(walletIds: {address.walletId});
          if (wallet.id == pros.settings.currentWalletId) {
            streams.app.wallet.refresh.add(true);
          }
          startupProcessRunning = false;
          if (!services.download.history.busy) {
            /// CLAIM FEATURE
            if (streams.claim.unclaimed.value.isNotEmpty) {
              /// CLAIM FEATURE, do nothing.
            } else {
              await services.download.history
                  .aggregatedDownloadProcess(wallet.addresses);
              // Ideally we'd call this once rather than per wallet.
              //if (services.download.history.calledAllDoneProcess == 0) {
              if (!services.wallet.currentWallet.minerMode) {
                await services.download.history.allDoneProcess();
              }
            }
          }
          streams.client.activity.add(ActivityMessage(active: false));
          if (services.wallet.leader.newLeaderProcessRunning) {
            if (pros.balances.isNotEmpty) {
              streams.app.snack.add(Snack(message: 'Import Successful'));
            }
            streams.client.activity.add(ActivityMessage(
                active: true,
                title: 'Syncing with the network',
                message: 'Downloading your transaction history...'));

            /// remove unnecessary vouts to minimize size of database and load time
            //await pros.vouts.clearUnnecessaryVouts();

            services.wallet.leader.newLeaderProcessRunning = false;
          }
          Wallet currentWallet = services.wallet.currentWallet;
          if (wallet.id == pros.settings.currentWalletId ||
              (currentWallet is LeaderWallet &&
                  services.wallet.leader.gapSatisfied(currentWallet) &&
                  subscriptionHandlesAddress
                      .containsKey(pros.settings.currentWalletId) &&
                  subscriptionHandlesAddress[pros.settings.currentWalletId]!
                          .keys
                          .length ==
                      currentWallet.addresses.length)) {
            streams.client.busy.add(false);
            streams.app.wallet.refresh.add(true);
          }
        }
      });
    }
  }

  void broadcastActivity({String? address, String? status}) {
    streams.client.download.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: address == null
            ? status ?? 'Downloading your transactions...'
            : 'Discovered ${status == null ? '' : '$status '}address: $address'));
    print('$status $address');
  }

  Future subscribeAsset(Asset asset) async {
    if (!subscriptionHandlesAsset.keys.contains(asset.symbol)) {
      subscriptionHandlesAsset[asset.symbol] =
          (await services.client.api.subscribeAsset(asset))
              .listen((String? status) {
        if (asset.status?.status != status) {
          pros.statuses.save(Status(
              linkId: asset.symbol,
              statusType: StatusType.asset,
              status: status));
          //Handles saving the asset meta & the security
          services.download.asset.get(asset.symbol);
        }
      });
    }
  }

  void unsubscribeAddress(Address address) =>
      unsubscribeAddressByIds(address.walletId, address.id);

  void unsubscribeAddressByIds(String wallet, String address) =>
      (subscriptionHandlesAddress[wallet] ?? {}).remove(address)?.cancel();

  void unsubscribeAddressesAll() {
    var toRemove = [];
    for (var wallet in subscriptionHandlesAddress.keys) {
      for (var address in subscriptionHandlesAddress[wallet]!.keys) {
        toRemove.add([wallet, address]);
      }
    }
    for (var remove in toRemove) {
      unsubscribeAddressByIds(remove[0], remove[1]);
    }
  }

  void unsubscribeAsset(String asset) =>
      subscriptionHandlesAsset.remove(asset)?.cancel();

  void unsubscribeAssetsAll() {
    var toRemove = [];

    for (var asset in subscriptionHandlesAsset.keys) {
      toRemove.add(asset);
    }
    for (var remove in toRemove) {
      unsubscribeAsset(remove);
    }
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
