import 'package:equatable/equatable.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven_back/utilities/hex.dart' as hex;

import 'package:raven_back/utilities/seed_wallet.dart';
import 'package:raven_back/raven_back.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final int requiredGap = 20;
  Set backlog = <LeaderWallet>{};
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

  void updateIndexes() {
    for (var leader in res.wallets.leaders) {
      updateIndex(leader);
    }
  }

  /// this function allows us to avoid creating a 'hdindex' reservoir,
  /// which is nice. this is why
  void updateIndex(LeaderWallet leader) {
    for (var exposure in [NodeExposure.External, NodeExposure.Internal]) {
      var addresses =
          res.addresses.byWalletExposure.getAll(leader.id, exposure);
      services.wallet.leader.updateIndexOf(
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

  bool gapSatisfied(LeaderWallet leader, NodeExposure exposure) =>
      requiredGap - (getIndexOf(leader, exposure).currentGap) <= 0;

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
  }) {
    return leaderWallet.getUnusedAddress(exposure)!.address;
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
    var generate = requiredGap - getIndexOf(leaderWallet, exposure).currentGap;
    var target = 0;
    target = getIndexOf(leaderWallet, exposure).saved + generate;
    if (generate > 0) {
      var futures = <Future<Address>>[
        for (var i = target - generate + 1; i <= target; i++)
          () async {
            return deriveAddress(leaderWallet, i, exposure: exposure);
          }()
      ];
      var ret = (await Future.wait(futures)).toSet();
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
      var s = Stopwatch()..start();
      var derivedAddresses = await deriveNextAddresses(
        wallet,
        res.ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
      );
      newAddresses.addAll(derivedAddresses);
      updateIndexOf(wallet, exposure, savedPlus: derivedAddresses.length);
    }
    await res.addresses.saveAll(newAddresses);
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
