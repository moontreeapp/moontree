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
  final int requiredGap = 2;

  int currentGap(LeaderWallet leaderWallet, NodeExposure exposure) =>
      exposure == NodeExposure.External
          ? leaderWallet.emptyExternalAddresses.length
          : leaderWallet.emptyInternalAddresses.length;

  int missingGap(LeaderWallet leaderWallet, NodeExposure exposure) =>
      requiredGap - currentGap(leaderWallet, exposure);

  bool gapSatisfied(LeaderWallet leaderWallet, NodeExposure exposure) =>
      requiredGap - currentGap(leaderWallet, exposure) <= 0;

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
          LeaderWallet wallet, int hdIndex, NodeExposure exposure) =>
      getSeedWallet(wallet).subwallet(hdIndex, exposure: exposure);

  HDWallet getSubWalletFromAddress(Address address) =>
      getSeedWallet(address.wallet! as LeaderWallet)
          .subwallet(address.hdIndex, exposure: address.exposure);

  /// returns the next internal or external node missing a history
  String getNextEmptyAddress(
    LeaderWallet leaderWallet, {
    NodeExposure exposure = NodeExposure.Internal,
  }) {
    var addresses = exposure == NodeExposure.Internal
        ? leaderWallet.emptyInternalAddresses
        : leaderWallet.emptyExternalAddresses;
    if (addresses.isNotEmpty) {
      return addresses.first.address;
    }
    //TODO derive a new address and return that.
    return '';
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
  Set<Address> deriveNextAddresses(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) {
    var existingGap = currentGap(leaderWallet, exposure);
    var usedCount = exposure == NodeExposure.External
        ? leaderWallet.usedExternalAddresses.length
        : leaderWallet.usedInternalAddresses.length;
    var hdIndex = (existingGap + usedCount - 1);
    //if (existingGap < requiredGap) {
    return {
      //for (var i = 0; i <= requiredGap - existingGap; i++)
      deriveAddress(leaderWallet, hdIndex + 1, exposure: exposure)
    };
    //}
    //return {};
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);

  Set<Address> deriveMoreAddresses(
    LeaderWallet wallet, {
    List<NodeExposure>? exposures,
  }) {
    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    for (var exposure in exposures) {
      newAddresses.addAll(deriveNextAddresses(
        wallet,
        res.ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
      ));
    }
    res.addresses.saveAll(newAddresses);
    return newAddresses;
  }
}
