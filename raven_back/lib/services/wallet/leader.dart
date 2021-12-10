import 'package:raven_back/utils/enum.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_back/utils/seed_wallet.dart';
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

  void maybeSaveNewAddress(
      LeaderWallet leaderWallet, CipherBase cipher, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet, cipher, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determine if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) {
    var currentGap = exposure == NodeExposure.External
        ? leaderWallet.emptyExternalAddresses.length
        : leaderWallet.emptyInternalAddresses.length;
    var usedCount = exposure == NodeExposure.External
        ? leaderWallet.usedExternalAddresses.length
        : leaderWallet.usedInternalAddresses.length;
    if (currentGap < requiredGap) {
      return deriveAddress(leaderWallet, usedCount, exposure: exposure);
    }
  }

  Address deriveAddress(
    LeaderWallet wallet,
    int hdIndex, {
    exposure = NodeExposure.External,
  }) {
    addressRegistry[addressRegistryKey(wallet, exposure)] = hdIndex;
    var subwallet = getSubWallet(wallet, hdIndex, exposure);
    return Address(
        addressId: subwallet.scripthash,
        address: subwallet.address!,
        walletId: wallet.walletId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: wallet.account!.net);
  }

  SeedWallet getSeedWallet(LeaderWallet wallet) {
    var encryptedEntropy =
        EncryptedEntropy(wallet.encryptedEntropy, wallet.cipher!);
    return SeedWallet(encryptedEntropy.seed, wallet.account!.net);
  }

  HDWallet getSubWallet(
          LeaderWallet wallet, int hdIndex, NodeExposure exposure) =>
      getSeedWallet(wallet).subwallet(hdIndex, exposure: exposure);

  HDWallet getSubWalletFromAddress(Address address) =>
      getSeedWallet(address.wallet! as LeaderWallet)
          .subwallet(address.hdIndex, exposure: address.exposure);

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(LeaderWallet leaderWallet,
      {NodeExposure exposure = NodeExposure.Internal}) {
    var seedWallet = getSeedWallet(leaderWallet);
    var i = 0;
    while (true) {
      var hdWallet = seedWallet.subwallet(i, exposure: exposure);
      if (vouts.byAddress.getAll(hdWallet.address!).isEmpty) {
        return hdWallet;
      }
      i++;
    }
  }

  LeaderWallet? makeLeaderWallet(
    String accountId,
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? entropy,
    bool alwaysReturn = false,
  }) {
    services.busy.createWalletOn();
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    var encryptedEntropy = EncryptedEntropy.fromEntropy(entropy, cipher);
    var existingWallet = wallets.primaryIndex.getOne(encryptedEntropy.walletId);
    services.busy.createWalletOff();
    if (existingWallet == null) {
      return LeaderWallet(
        walletId: encryptedEntropy.walletId,
        accountId: accountId,
        encryptedEntropy: encryptedEntropy.encryptedSecret,
        cipherUpdate: cipherUpdate,
      );
    }
    if (alwaysReturn) return existingWallet as LeaderWallet;
  }

  Future<void> makeSaveLeaderWallet(String accountId, CipherBase cipher,
      {required CipherUpdate cipherUpdate, String? mnemonic}) async {
    var leaderWallet = makeLeaderWallet(accountId, cipher,
        cipherUpdate: cipherUpdate,
        entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null);
    if (leaderWallet != null) {
      await wallets.save(leaderWallet);
    }
  }

  /// this function is used to determine if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Set<Address> maybeDeriveNextAddresses(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) {
    var existingGap = currentGap(leaderWallet, exposure);
    var usedCount = exposure == NodeExposure.External
        ? leaderWallet.usedExternalAddresses.length
        : leaderWallet.usedInternalAddresses.length;
    var expectedhdIndex = (existingGap + usedCount - 1);
    var hdIndexKey = addressRegistryKey(leaderWallet, exposure);
    addressRegistry[hdIndexKey] =
        addressRegistry[hdIndexKey] ?? expectedhdIndex;
    var hdIndex = addressRegistry[hdIndexKey]!;
    if (existingGap < requiredGap) {
      return {
        //for (var i = 0; i <= requiredGap - existingGap; i++)
        deriveAddress(leaderWallet, hdIndex + 1, exposure: exposure)
      };
    }
    return {};
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);

  String addressRegistryKey(LeaderWallet wallet, NodeExposure exposure) =>
      '${wallet.walletId}:${describeEnum(exposure)}';

  Set<Address> deriveMoreAddresses(
    LeaderWallet wallet, {
    List<NodeExposure>? exposures,
  }) {
    services.busy.addressDerivationOn();
    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    for (var exposure in exposures) {
      newAddresses.addAll(maybeDeriveNextAddresses(
        wallet,
        ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
      ));
    }
    addresses.saveAll(newAddresses);
    services.busy.addressDerivationOff();
    return newAddresses;
  }
}
