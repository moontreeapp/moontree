// ignore_for_file: omit_local_variable_types

import 'package:equatable/equatable.dart';
import 'package:raven_back/streams/client.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven_back/utilities/hex.dart' as hex;

import 'package:raven_back/utilities/seed_wallet.dart';
import 'package:raven_back/raven_back.dart';
import 'package:tuple/tuple.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final HDIndexRegistry registry = HDIndexRegistry();
  final int requiredGap = 20;
  bool newLeaderProcessProcessing = false;

  // necessary anymore?
  Set backlog = <LeaderWallet>{};

  void updateIndexes() {
    for (var leader in res.wallets.leaders) {
      registry.updateIndex(leader);
    }
  }

  void updateCounts(Address address, LeaderWallet leader) {
    leader.removeUnused(address.hdIndex, address.exposure);
    registry.updateIndexOf(leader, address.exposure, used: address.hdIndex);
  }

  void updateCache(Address address, LeaderWallet leader) {
    leader.addUnused(address.hdIndex, address.exposure);
    registry.updateIndexOf(leader, address.exposure, saved: address.hdIndex);
  }

  bool gapSatisfied(LeaderWallet leader, NodeExposure exposure) {
    final index = registry.getIndexOf(leader, exposure);
    //print('${index.currentGap} ${index.used} ${index.saved}');
    return requiredGap - index.currentGap <= 0;
  }

  Future<void> backedUp(LeaderWallet leader) async {
    await res.wallets.save(LeaderWallet.from(leader, backedUp: true));
  }

  /// maybe we don't need the stream:
  Future<bool> needsBackup(LeaderWallet leader) async =>
      (await services.download.unspents.getSymbols()).isNotEmpty &&
      !leader.backedUp;

  /// we have a linear process for handling new leaders (those w/o addresses):
  ///   Derive, get histories by address in batch, derive until done.
  ///   Get unspents in batch.
  ///   Build balances.
  ///   Get transactions in batch by address, or by arbitrary batch number.
  ///   Get dangling transactions
  ///   Get status of addresses, save
  ///   Save addresses - this will trigger the general case, but since we've
  ///     already saved the most recent status nothing will happen.
  Future<void> newLeaderProcess(LeaderWallet leader) async {
    //  newLeaders.add(leader.id); actually just save the addresses at the end
    print('newLeaderProcess');
    newLeaderProcessProcessing = true;
    streams.client.busy.add(true);
    streams.client.activity.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: 'Downloading your balances...'));

    // matching orders for lists
    Map<NodeExposure, List<Address>> addresses = {};
    Map<NodeExposure, List<List<String>>> transactionIds = {};

    /// Derive, get histories by address in batch, derive until done.
    for (var exposure in NodeExposure.values) {
      addresses[exposure] = [];
      transactionIds[exposure] = [];
      var generate = requiredGap;
      while (generate > 0) {
        final target = transactionIds[exposure]!.length + generate;
        var futures = <Future<Address>>[
          for (var i = target - generate + 1; i <= target; i++)
            () async {
              return deriveAddress(leader, i, exposure: exposure);
            }()
        ];
        var currentAddresses = (await Future.wait(futures)).toList();
        addresses[exposure]!.addAll(currentAddresses);
        transactionIds[exposure]!.addAll(
            await services.download.history.getHistories(currentAddresses));
        generate = requiredGap -
            transactionIds[exposure]!
                .sublist(transactionIds[exposure]!.length - requiredGap)
                .where((element) => element.isEmpty)
                .length;
      }

      /// save final cache and counts for this wallet exposure
      for (Tuple2<int, List<String>> et
          in transactionIds[exposure]!.enumeratedTuple()) {
        var addr = addresses[exposure]![et.item1];
        if (et.item2.isEmpty) {
          updateCache(addr, leader);
        } else {
          updateCounts(addr, leader);
        }
      }

      /// Get unspents in batch.
      /// not sure if anything has to change in unspents.
      /// I'm hoping this initialization process can simplify it.
      await services.download.unspents
          .pull(scripthashes: addresses[exposure]!.map((a) => a.scripthash));
    }

    /// Build balances. - this will update the holdings list UI (home page)
    await services.balance.recalculateAllBalances();

    streams.client.activity.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: 'Downloading your transaction history...'));

    /// Get status of addresses, save
    // you'll have to subscribe then unsubscribe. in batch.
    for (var exposure in NodeExposure.values) {
      await services.client.subscribe
          .onlySubscribeForStatuses(addresses[exposure]!);
    }

    /// Get transactions in batch by address, or by arbitrary batch number. -
    ///  must save these
    for (var exposure in NodeExposure.values) {
      var batchSize = 20;
      var txsToDownload = transactionIds[exposure]!.expand((e) => e).toList();
      while (txsToDownload.isNotEmpty) {
        final chunkSize =
            txsToDownload.length < batchSize ? txsToDownload.length : batchSize;
        await services.download.history.getTransactions(// also saves them
            txsToDownload.sublist(0, chunkSize));
        txsToDownload = txsToDownload.sublist(chunkSize);
      }
    }

    /// Get dangling transactions - by the way we'll still need a way for the
    ///  transaction screen to know if it's in the middle of downloading txs.
    await services.download.history.allDoneProcess();

    /// Save addresses - this will trigger the general case, but since we've
    ///   already saved the most recent status nothing will happen.
    for (var exposure in NodeExposure.values) {
      await res.addresses.saveAll(addresses[exposure]!);
    }

    /// remove unnecessary vouts to minimize size of database and load time
    await res.vouts.clearUnnecessaryVouts();

    streams.client.busy.add(false);
    streams.client.activity.add(ActivityMessage(active: false));
    newLeaderProcessProcessing = false;
    print('newLeaderProcess Done!');
  }

  Address deriveAddress(
    LeaderWallet wallet,
    int hdIndex, {
    exposure = NodeExposure.External,
  }) {
    var subwallet = getSubWallet(wallet, hdIndex, exposure);
    return Address(
        id: subwallet.scripthash,
        address: subwallet.address!,
        walletId: wallet.id,
        hdIndex: hdIndex,
        exposure: exposure,
        net: res.settings.net);
  }

  SeedWallet getSeedWallet(LeaderWallet wallet) {
    return SeedWallet(wallet.seed, res.settings.net);
  }

  HDWallet getSubWallet(
    LeaderWallet wallet,
    int hdIndex,
    NodeExposure exposure,
  ) =>
      getSeedWallet(wallet).subwallet(hdIndex, exposure: exposure);

  HDWallet getSubWalletFromAddress(Address address) =>
      getSeedWallet(address.wallet as LeaderWallet)
          .subwallet(address.hdIndex, exposure: address.exposure);

  /// returns the next internal or external node missing a history
  String getNextEmptyAddress(
    LeaderWallet leaderWallet, {
    NodeExposure exposure = NodeExposure.Internal,
    bool random = false,
  }) {
    return random
        ? leaderWallet.getRandomUnusedAddress(exposure)!.address
        : leaderWallet.getUnusedAddress(exposure)!.address;
  }

  /// returns the next change address
  String getNextChangeAddress(LeaderWallet leaderWallet) {
    return getNextEmptyAddress(leaderWallet, exposure: NodeExposure.Internal);
  }

  HDWallet getNextEmptyWallet(
    LeaderWallet leaderWallet, {
    NodeExposure exposure = NodeExposure.Internal,
  }) {
    var seedWallet = getSeedWallet(leaderWallet);
    var i = 0;
    while (true) {
      var hdWallet = seedWallet.subwallet(i, exposure: exposure);
      if (res.vouts.byAddress.getAll(hdWallet.address!).isEmpty) {
        return hdWallet;
      }
      i++;
    }
  }

  LeaderWallet? makeLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? entropy,
    bool alwaysReturn = false,
    String? name,
  }) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    final mnemonic = bip39.entropyToMnemonic(entropy);
    final seed = bip39.mnemonicToSeed(mnemonic);
    final newId = HDWallet.fromSeed(seed).pubKey;
    final encrypted_entropy = hex.encrypt(entropy, cipher);

    var existingWallet = res.wallets.primaryIndex.getOne(newId);
    if (existingWallet == null) {
      return LeaderWallet(
          id: newId,
          encryptedEntropy: encrypted_entropy,
          cipherUpdate: cipherUpdate,
          name: name ?? res.wallets.nextWalletName);
    }
    if (alwaysReturn) return existingWallet as LeaderWallet;
    return null;
  }

  void makeFirstWallet(Cipher currentCipher) {
    if (res.wallets.isEmpty) {
      makeSaveLeaderWallet(
        currentCipher.cipher,
        cipherUpdate: currentCipher.cipherUpdate,
      );
    }
  }

  Future<void> makeSaveLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? mnemonic,
    String? name,
  }) async {
    var leaderWallet = makeLeaderWallet(
      cipher,
      cipherUpdate: cipherUpdate,
      entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null,
      name: name,
    );
    if (leaderWallet != null) {
      await res.wallets.save(leaderWallet);
    }
  }

  /// this function is used to determine if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Future<Set<Address>> deriveNextAddresses(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) async {
    // get current gap from cache.
    var generate =
        requiredGap - registry.getIndexOf(leaderWallet, exposure).currentGap;
    //print('Want to generate $generate for $exposure');
    var target = 0;
    target = registry.getIndexOf(leaderWallet, exposure).saved + generate;
    if (generate > 0) {
      var futures = <Future<Address>>[
        for (var i = target - generate + 1; i <= target; i++)
          () async {
            return deriveAddress(leaderWallet, i, exposure: exposure);
          }()
      ];
      var ret = (await Future.wait(futures)).toSet();
      //print(ret);
      return ret;
    }
    return {};
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);

  /// deriveMoreAddresses also updates the cache we keep of highest saved
  /// addresses for each wallet-exposure. It does so after addresses are
  /// actually saved. the reason for this is that if we update the count to
  /// be higher than the number of addresses actually saved, we'll enter an
  /// infinite loop.
  Future<void> deriveMoreAddresses(
    LeaderWallet wallet, {
    List<NodeExposure>? exposures,
  }) async {
    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    for (var exposure in exposures) {
      var derivedAddresses = await deriveNextAddresses(
        wallet,
        res.ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
      );
      newAddresses.addAll(derivedAddresses);
      registry.updateIndexOf(wallet, exposure,
          savedPlus: derivedAddresses.length);
    }
    await res.addresses.saveAll(newAddresses);
    for (final address in newAddresses) {
      await services.client.subscribe.toAddress(address);
    }
  }
}

class LeaderExposureKey with EquatableMixin {
  LeaderWallet leader;
  NodeExposure exposure;

  LeaderExposureKey(this.leader, this.exposure);

  String get key => produceKey(leader.id, exposure);
  static String produceKey(String walletId, NodeExposure exposure) =>
      walletId + exposure.enumString;

  @override
  List<Object> get props => [leader, exposure];

  @override
  String toString() => 'LeaderExposureKey($leader, $exposure)';
}

class LeaderExposureIndex {
  int saved = 0;
  int used = 0;

  LeaderExposureIndex({this.saved = -1, this.used = -1});

  int get currentGap => saved - used;

  void updateSaved(int value) => saved = value > saved ? value : saved;
  void updateUsed(int value) => used = value > used ? value : used;
  void updateSavedPlus(int value) => saved = saved + value;
  void updateUsedPlus(int value) => used = used + value;
}

class HDIndexRegistry {
  Map<LeaderExposureKey, LeaderExposureIndex> indexRegistry = {};

  /// caching optimization
  LeaderExposureIndex getIndexOf(LeaderWallet leader, NodeExposure exposure) {
    var key = LeaderExposureKey(leader, exposure);
    if (!indexRegistry.keys.contains(key)) {
      indexRegistry[key] = LeaderExposureIndex();
    }
    return indexRegistry[key]!;
  }

  LeaderExposureIndex getIndexOfKey(
      LeaderWallet leader, NodeExposure exposure) {
    var key = LeaderExposureKey(leader, exposure);
    if (!indexRegistry.keys.contains(key)) {
      indexRegistry[key] = LeaderExposureIndex();
    }
    return indexRegistry[key]!;
  }

  void updateIndexOf(
    LeaderWallet leader,
    NodeExposure exposure, {
    int? saved,
    int? used,
    int? savedPlus,
    int? usedPlus,
  }) {
    var key = LeaderExposureKey(leader, exposure);
    if (!indexRegistry.keys.contains(key)) {
      indexRegistry[key] = LeaderExposureIndex();
    }
    if (saved != null) {
      indexRegistry[key]!.updateSaved(saved);
    }
    if (used != null) {
      indexRegistry[key]!.updateUsed(used);
    }
    if (savedPlus != null) {
      indexRegistry[key]!.updateSavedPlus(savedPlus);
    }
    if (usedPlus != null) {
      indexRegistry[key]!.updateUsedPlus(usedPlus);
    }
  }

  /// this function allows us to avoid creating a 'hdindex' reservoir,
  /// which is nice. this is why
  void updateIndex(LeaderWallet leader) {
    for (var exposure in [NodeExposure.External, NodeExposure.Internal]) {
      var addresses =
          res.addresses.byWalletExposure.getAll(leader.id, exposure);
      updateIndexOf(
        leader,
        exposure,
        saved: addresses.map((a) => a.hdIndex).max,
        used: addresses
            .where((a) => a.vouts.isNotEmpty)
            .map((a) => a.hdIndex)
            .max,
      );
    }
  }
}
