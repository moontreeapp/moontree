// ignore_for_file: omit_local_variable_types, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:moontree_utils/extensions/map.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/utilities/database.dart' as database;

/// client creation, logic, and settings.s
class ClientService {
  final SubscribeService subscribe = SubscribeService();
  final ApiService api = ApiService();
  final ReaderWriterLock _clientLock = ReaderWriterLock();
  RavenElectrumClient? ravenElectrumClient;
  DateTime lastActiveTime = DateTime.now();
  static const Duration inactiveGracePeriod = Duration(seconds: 10);

  StreamSubscription<int>? periodicTimer;

  String get serverUrl =>
      '${services.client.currentDomain}:${services.client.currentPort}';

  Future<RavenElectrumClient> get client async {
    final RavenElectrumClient? x = ravenElectrumClient;
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
    T? x;
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
    return x as T;
  }

  String get electrumDomain =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_domain)!.value
          as String;

  int get electrumPort =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_port)!.value
          as int;

  String get currentDomain =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_domain)!.value
          as String;

  int get currentPort =>
      pros.settings.primaryIndex.getOne(SettingName.electrum_port)!.value
          as int;

  bool get connectionStatus => !(ravenElectrumClient?.peer.isClosed ?? true);

  Future<void> disconnect() async {
    streams.client.connected.add(ConnectionStatus.disconnected);
    ravenElectrumClient = null;
  }

  /// we want exclusive access to the creation of the client so that we
  /// don't create many connections to the electrum server all at once.
  /// here we return a client, even though we also save it to the singleton
  /// because if we return void this function will not be awaited and therefore
  /// succeeding calls may try to use the client that is not yet created.
  Future<RavenElectrumClient?> createClient() async {
    print('creating Client');
    lastActiveTime = DateTime.now();
    await periodicTimer?.cancel();
    periodicTimer =
        Stream<int>.periodic(inactiveGracePeriod, (int count) => count++)
            .listen((_) async {
      if (streams.client.busy.value &&
          DateTime.now().difference(lastActiveTime).inSeconds >=
              inactiveGracePeriod.inSeconds) {
        streams.client.busy.add(false);
      }
    });
    return _clientLock.writeFuture(() async {
      streams.client.connected.add(ConnectionStatus.connecting);

      Future<RavenElectrumClient?> genClient() async {
        void registerCallbacks(RavenElectrumClient conn) {
          Future<void> reconnect(_) async {
            if (ravenElectrumClient?.peer.isClosed ?? true) {
              await createClient();
              return;
            }
          }

          conn.peer.done.then(
              (dynamic value) async =>
                  Future<dynamic>.delayed(const Duration(seconds: 1))
                      .then(reconnect),
              onError: (dynamic ob, dynamic st) async => reconnect(ob));
          conn.peer.done.whenComplete(() async =>
              Future<dynamic>.delayed(const Duration(seconds: 2))
                  .then(reconnect));
        }

        final RavenElectrumClient? newRavenClient = await _generateClient();
        if (newRavenClient != null) {
          ravenElectrumClient = newRavenClient;
          registerCallbacks(ravenElectrumClient!);
          streams.client.connected.add(ConnectionStatus.connected);
          return newRavenClient;
        } else {
          if (pros.settings.domainPort != pros.settings.defaultDomainPort) {
            streams.app.snack.add(Snack(
                message:
                    'Unable to connect to ${pros.settings.domainPort}, restoring defaults...'));
            await pros.settings.setDomainPortForChainNet();
            return genClient();
          }
        }
        return null;
      }

      return genClient();
    });
  }

  Future<RavenElectrumClient?> _generateClient({
    String projectName = 'moontree',
    String? projectVersion,
  }) async {
    if (pros.settings.domainPort != pros.settings.domainPortOfChainNet) {
      await pros.settings.setDomainPortForChainNet();
    }
    try {
      return await RavenElectrumClient.connect(
        electrumDomain,
        port: electrumPort,
        clientName: projectName,
        clientVersion: projectVersion ?? (services.version.current ?? 'v1.0'),
      );
    } on SocketException catch (_) {
      print(_);
    }
    return null;
  }

  Future<void> saveElectrumAddress({
    required String domain,
    required int port,
  }) async =>
      pros.settings.saveAll(<Setting>[
        Setting(name: SettingName.electrum_domain, value: domain),
        Setting(name: SettingName.electrum_port, value: port),
      ]);

  Future<void> switchNetworks({required Chain chain, required Net net}) async {
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

    /// no longer needed since the await waits for the client to be created
    //await Future<void>.delayed(Duration(seconds: 3));

    ///// the leader waiter does not do this:
    /// start derivation process
    if (!keepAddresses) {
      final Wallet currentWallet = services.wallet.currentWallet;
      if (currentWallet is LeaderWallet) {
        //print('deriving');
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
  final Map<String, Map<String, StreamSubscription<dynamic>>>
      subscriptionHandlesAddress =
      <String, Map<String, StreamSubscription<dynamic>>>{};
  final Map<String, StreamSubscription<dynamic>> subscriptionHandlesAsset =
      <String, StreamSubscription<dynamic>>{};
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
    final Iterable<String> walletIds =
        pros.wallets.records.map((Wallet e) => e.id);
    await pros.addresses.removeAll(pros.addresses.records
        .where((Address a) => !walletIds.contains(a.walletId)));

    // we have to update these counts incase the user logins before the processes is over
    final Set<Address> addresses = pros.addresses.toSet();
    final Set<Address> currentAddresses = (pros.wallets.primaryIndex
                .getOne(pros.settings.currentWalletId)
                ?.addresses ??
            <Address>[])
        .toSet();
    final Set<Address> otherAddresses = addresses.difference(currentAddresses);
    for (final Address address in currentAddresses) {
      await subscribeAddress(address);
    }
    for (final Address address in otherAddresses) {
      await subscribeAddress(address);
    }
    //if (addresses.isNotEmpty) {
    //  await services.download.history.allDoneProcess();
    //}
    return true;
  }

  bool toAllAssets() {
    pros.assets.forEach(subscribeAsset);
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

  Future<void> maybeDerive(Address address) async {
    // happens when you switch blockchains while the old process hasn't finished
    // I think this might cause the occasional freezing I've seen on emulator
    if ((address.address.startsWith('E') &&
            pros.settings.chain == Chain.ravencoin) ||
        (address.address.startsWith('R') &&
            pros.settings.chain == Chain.evrmore)) {
      return;
    }
    final Wallet? wallet = address.wallet;
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

  Future<void> pullUnspents(Address address) async {
    if ((address.address.startsWith('E') &&
            pros.settings.chain == Chain.ravencoin) ||
        (address.address.startsWith('R') &&
            pros.settings.chain == Chain.evrmore)) {
      return;
    }
    await services.download.unspents.pull(
      scripthashes: <String>{address.scripthash},
      wallet: address.wallet!,
      chain: pros.settings.chain,
      net: pros.settings.net,
    );
  }

  //void queueHistoryDownload(Address address) => null;
  //services.download.queue.update(address: address);

  Future<void> saveStatusUpdate(Address address, String? status) async {
    if ((address.address.startsWith('E') &&
            pros.settings.chain == Chain.ravencoin) ||
        (address.address.startsWith('R') &&
            pros.settings.chain == Chain.evrmore)) {
      return;
    }
    await pros.statuses.save(Status(
      linkId: address.id,
      statusType: StatusType.address,
      status: status,
    ));
  }

  Future<void> subscribeAddress(Address address) async {
    if (!subscriptionHandlesAddress.keys.contains(address.walletId)) {
      subscriptionHandlesAddress[address.walletId] =
          <String, StreamSubscription<dynamic>>{};
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
        final Status? addressStatus = address.status;
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
        final Wallet wallet = address.wallet!;

        /// end of process
        if (wallet is LeaderWallet &&
            services.wallet.leader.gapSatisfied(wallet) &&
            subscriptionHandlesAddress.containsKey(address.walletId) &&
            subscriptionHandlesAddress[address.walletId]!.keys.length ==
                wallet.addresses.length) {
          await services.balance
              .recalculateAllBalances(walletIds: <String>{address.walletId});
          if (wallet.id == pros.settings.currentWalletId) {
            streams.app.wallet.refresh.add(true);
          }
          startupProcessRunning = false;
          if (!services.download.history.busy) {
            /// CLAIM FEATURE
            if (streams.claim.unclaimed.value
                .getOr(wallet.id, <Vout>{}).isNotEmpty) {
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
          streams.client.activity.add(ActivityMessage());
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
          final Wallet currentWallet = services.wallet.currentWallet;
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
    if (address != null &&
        ((address.startsWith('E') && pros.settings.chain == Chain.ravencoin) ||
            (address.startsWith('R') &&
                pros.settings.chain == Chain.evrmore))) {
      print('trying to download transactions for the wrong chain...');
    }
    streams.client.download.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: address == null
            ? status ?? 'Downloading your transactions...'
            : 'Discovered ${status == null ? '' : '$status '}address: $address'));
    print('$status $address');
  }

  Future<void> subscribeAsset(Asset asset) async {
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
      (subscriptionHandlesAddress[wallet] ??
              <String, StreamSubscription<dynamic>>{})
          .remove(address)
          ?.cancel();

  void unsubscribeAddressesAll() {
    final List<List<String>> toRemove = <List<String>>[];
    for (final String wallet in subscriptionHandlesAddress.keys) {
      for (final String address in subscriptionHandlesAddress[wallet]!.keys) {
        toRemove.add(<String>[wallet, address]);
      }
    }
    for (final List<String> remove in toRemove) {
      unsubscribeAddressByIds(remove[0], remove[1]);
    }
  }

  void unsubscribeAsset(String asset) =>
      subscriptionHandlesAsset.remove(asset)?.cancel();

  void unsubscribeAssetsAll() {
    final List<String> toRemove = <String>[];
    toRemove.addAll(subscriptionHandlesAsset.keys);
    toRemove.forEach(unsubscribeAsset);
  }
}

/// calls to the electrum server
class ApiService {
  Future<Stream<BlockHeader>> subscribeHeaders() async => services.client
      .scope(() async => (await services.client.client).subscribeHeaders());

  Future<Stream<String?>> subscribeAsset(Asset asset) async =>
      services.client.scope(() async =>
          (await services.client.client).subscribeAsset(asset.symbol));

  Future<Stream<String?>> subscribeAddress(Address address) async =>
      services.client.scope(() async => (await services.client.client)
          .subscribeScripthash(address.scripthash));

  Future<bool> unsubscribeAddress(Address address) async =>
      services.client.scope(() async => (await services.client.client)
          .unsubscribeScripthash(address.scripthash));

  Future<List<Stream<String?>>> subscribeAddresses(
    List<Address> addresses,
  ) async =>
      services.client.scope(() async => (await services.client.client)
          .subscribeScripthashes(addresses.map((Address a) => a.scripthash)));

  Future<void> unsubscribeAddresses(List<Address> addresses) async =>
      services.client.scope(() async => (await services.client.client)
          .unsubscribeScripthashes(addresses.map((Address a) => a.scripthash)));

  Future<List<List<ScripthashUnspent>>> getUnspents(
    Iterable<String> scripthashes,
  ) async =>
      services.client.scope(
          () async => (await services.client.client).getUnspents(scripthashes));

  Future<List<List<ScripthashUnspent>>> getAssetUnspents(
    Iterable<String> scripthashes,
  ) async =>
      services.client.scope(() async =>
          (await services.client.client).getAssetUnspents(scripthashes));

  Future<List<ScripthashHistory>> getHistory(Address address) async =>
      services.client.scope(() async =>
          (await services.client.client).getHistory(address.scripthash));

  Future<List<List<ScripthashHistory>>> getHistories(
    List<Address> addresses,
  ) async =>
      services.client.scope(() async => (await services.client.client)
          .getHistories(addresses.map((Address a) => a.scripthash)));

  Future<Tx> getTransaction(String transactionId) async =>
      services.client.scope(() async =>
          (await services.client.client).getTransaction(transactionId));

  Future<List<Tx>> getTransactions(Iterable<String> transactionIds) async =>
      services.client.scope(() async =>
          (await services.client.client).getTransactions(transactionIds));

  Future<String> sendTransaction(String rawTx) async => services.client.scope(
      () async => (await services.client.client).broadcastTransaction(rawTx));

  Future<AssetMeta?> getMeta(String symbol) async => services.client
      .scope(() async => (await services.client.client).getMeta(symbol));

  Future<String> getOwner(String symbol) async =>
      services.client.scope(() async => (await (await services.client.client)
              .getAddresses(symbol.endsWith('!') ? symbol : '$symbol!'))!
          .owner);

  /// unsued: avoid this and ping directly to catch errors
  Future<dynamic> ping() async => services.client.scope(() async {
        final dynamic result = await (await services.client.client).ping();
        //print('ping result: $result'); // null
        return result;
      });

  /// we should instead just be able to send an empty string and make one call
  /// this returns too much data to be useful. we don't use this anymore.
  Future<Iterable<dynamic>> getAllAssetNames() async => <Iterable<dynamic>>[
        for (String char
            in 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split(''))
          await services.client.scope(() async =>
              (await services.client.client).getAssetsByPrefix(char))
      ].expand((Iterable<dynamic> i) => i);

  Future<Iterable<String>> getAssetNames(String prefix) async =>
      prefix.length >= 3
          ? await services.client.scope(() async =>
              await (await services.client.client).getAssetsByPrefix(prefix)
                  as Iterable<String>)
          : <String>[];
}
