import 'package:raven/utils/enum.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/utils/seed_wallet.dart';
import 'package:raven/raven.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final Map<String, int> addressRegistry = {
    /* walletId + exposure : highest hdIndex created*/
  };
  final int requiredGap = 1;

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
    var subwallet =
        getSeedWallet(wallet).subwallet(hdIndex, exposure: exposure);
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

  LeaderWallet? makeLeaderWallet(String accountId, CipherBase cipher,
      {required CipherUpdate cipherUpdate,
      String? entropy,
      bool alwaysReturn = false}) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    var encryptedEntropy = EncryptedEntropy.fromEntropy(entropy, cipher);
    var existingWallet = wallets.primaryIndex.getOne(encryptedEntropy.walletId);
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
    NodeExposure exposure, {
    int witnessedHDIndex = 0,
  }) {
    var currentGap = exposure == NodeExposure.External
        ? leaderWallet.emptyExternalAddresses.length
        : leaderWallet.emptyInternalAddresses.length;
    var usedCount = exposure == NodeExposure.External
        ? leaderWallet.usedExternalAddresses.length
        : leaderWallet.usedInternalAddresses.length;
    var expectedhdIndex = (currentGap + usedCount - 1);
    var hdIndexKey = addressRegistryKey(leaderWallet, exposure);
    addressRegistry[hdIndexKey] =
        addressRegistry[hdIndexKey] ?? expectedhdIndex;
    var hdIndex = addressRegistry[hdIndexKey]!;
    if (currentGap < requiredGap) {
      return {deriveAddress(leaderWallet, hdIndex + 1, exposure: exposure)};
    }
    //if (witnessedHDIndex + 1 >= usedCount) {
    //  var newAddresses = {
    //    for (var i = 0; i < requiredGap - currentGap; i++)
    //      deriveAddress(leaderWallet, usedCount + i, exposure: exposure)
    //  };
    //  if (leaderWallet.walletId ==
    //      '03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342') {
    //    print('witnessedHDIndex, $witnessedHDIndex');
    //    print('exposure, $exposure');
    //    print('usedCount $usedCount');
    //    print('currentGap $currentGap');
    //    print('newAddresses ${newAddresses.map((a) => a.address)}');
    //    //if (exposure == NodeExposure.Internal) {
    //    //  print(leaderWallet.emptyInternalAddresses);
    //    //}
    //  }
    //  return newAddresses;
    //}
    return {};
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);

  String addressRegistryKey(LeaderWallet wallet, NodeExposure exposure) =>
      '${wallet.walletId}:${describeEnum(exposure)}';
}
