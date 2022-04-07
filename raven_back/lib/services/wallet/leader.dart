import 'package:ravencoin_wallet/ravencoin_wallet.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven_back/utilities/hex.dart' as hex;

import 'package:raven_back/utilities/seed_wallet.dart';
import 'package:raven_back/raven_back.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final Map<String, int> addressRegistry = {
    /* walletId + exposure : highest hdIndex created*/
  };
  Set<LeaderWallet> backlog = {};
  final int requiredGap = 20;

  bool gapSatisfied(LeaderWallet leaderWallet, NodeExposure exposure) =>
      requiredGap - leaderWallet.currentGap(exposure) <= 0;

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
    NodeExposure exposure, {
    bool justOne = false,
  }) async {
    // get current gap from cache.
    var generate =
        justOne ? 1 : requiredGap - leaderWallet.currentGap(exposure);
    var target = 0;
    target = leaderWallet.getHighestSavedIndex(exposure) + generate;
    print('Starting: ${target - generate}');
    print('Derive target: $target');
    if (generate > 0) {
      var futures = <Future<Address>>[
        for (var i = target - generate + 1; i <= target; i++)
          () async {
            return deriveAddress(leaderWallet, i, exposure: exposure);
          }()
      ];

      return (await Future.wait(futures)).toSet();
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
    bool justOne = false,
  }) async {
    void updateCacheCounts(int internalCount, int externalCount) {
      if (internalCount > 0 || externalCount > 0) {
        res.wallets.save(LeaderWallet.from(
          wallet,
          highestSavedInternalIndex:
              wallet.highestSavedInternalIndex + internalCount,
          highestSavedExternalIndex:
              wallet.highestSavedExternalIndex + externalCount,
          seed: wallet.seed,
        ));
      }
    }

    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    var internalCount = 0;
    var externalCount = 0;
    for (var exposure in exposures) {
      var s = Stopwatch()..start();
      var derivedAddresses = await deriveNextAddresses(
        wallet,
        res.ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
        justOne: justOne,
      );
      print('derive Address: ${s.elapsed}');
      newAddresses.addAll(derivedAddresses);
      if (exposure == NodeExposure.Internal) {
        internalCount = derivedAddresses.length;
      } else {
        externalCount = derivedAddresses.length;
      }
    }
    await res.addresses.saveAll(newAddresses);
    updateCacheCounts(internalCount, externalCount);
  }
}
