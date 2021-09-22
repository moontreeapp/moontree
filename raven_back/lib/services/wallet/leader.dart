import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/security/cipher.dart';
import 'package:raven/security/encrypted_entropy.dart';
import 'package:raven/utils/seed_wallet.dart';
import 'package:raven/raven.dart';

// derives addresses for leaderwallets
class LeaderWalletService {
  /// [Address(walletid=0...),]
  void maybeDeriveNewAddresses(
      List<Address> changedAddresses, CipherRegistry cipherRegistry) async {
    for (var address in changedAddresses) {
      var leaderWallet =
          wallets.primaryIndex.getOne(address.walletId)! as LeaderWallet;
      maybeSaveNewAddress(
          leaderWallet,
          cipherRegistry.ciphers[leaderWallet.cipherUpdate]!,
          NodeExposure.Internal);
      maybeSaveNewAddress(
          leaderWallet,
          cipherRegistry.ciphers[leaderWallet.cipherUpdate]!,
          NodeExposure.External);
    }
  }

  void maybeSaveNewAddress(
      LeaderWallet leaderWallet, Cipher cipher, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet, cipher, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(
    LeaderWallet leaderWallet,
    Cipher cipher,
    NodeExposure exposure,
  ) {
    var gap = 0;
    var exposureAddresses =
        addresses.byWalletExposure.getAll(leaderWallet.walletId, exposure);
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (histories.byScripthash.getAll(exposureAddress.scripthash).isEmpty
              ? 1
              : 0);
    }
    if (gap < 10) {
      return deriveAddress(leaderWallet, cipher, exposureAddresses.length,
          exposure: exposure);
    }
  }

  // Address deriveAddress(
  //   LeaderWallet wallet,
  //   int hdIndex,
  //   NodeExposure exposure,
  // ) {
  //   var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
  //   return wallet.deriveAddress(net, hdIndex, exposure);
  // }
  Address deriveAddress(
    LeaderWallet wallet,
    Cipher cipher,
    int hdIndex, {
    exposure = NodeExposure.External,
  }) {
    // var encryptedEntropy = EncryptedEntropy(wallet.encryptedEntropy, cipher);
    // var seedWallet = SeedWallet(encryptedEntropy.seed, wallet.account!.net);
    var subwallet =
        getSeedWallet(wallet, cipher).subwallet(hdIndex, exposure: exposure);
    return Address(
        scripthash: subwallet.scripthash,
        address: subwallet.address!,
        walletId: wallet.walletId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: wallet.account!.net);
  }

  SeedWallet getSeedWallet(LeaderWallet wallet, Cipher cipher) {
    var encryptedEntropy = EncryptedEntropy(wallet.encryptedEntropy, cipher);
    return SeedWallet(encryptedEntropy.seed, wallet.account!.net);
  }

  void deriveFirstAddressAndSave(
    LeaderWallet wallet,
    Cipher cipher,
  ) {
    var addrInt =
        deriveAddress(wallet, cipher, 0, exposure: NodeExposure.Internal);
    addresses.save(addrInt);
    var addrExt =
        deriveAddress(wallet, cipher, 0, exposure: NodeExposure.External);
    addresses.save(addrExt);
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(
    String walletId,
    Cipher cipher, [
    NodeExposure exposure = NodeExposure.Internal,
  ]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var leaderWallet = wallets.primaryIndex.getOne(walletId)! as LeaderWallet;
    var seedWallet = getSeedWallet(leaderWallet, cipher);
    var i = 0;
    for (var address in addresses.byWalletExposure.getAll(walletId, exposure)) {
      if (histories.byScripthash.getAll(address.scripthash).isEmpty) {
        return seedWallet.subwallet(i, exposure: exposure);
        //return leaderWallet.deriveWallet(i, exposure); // service
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return seedWallet.subwallet(i, exposure: exposure);
  }

  LeaderWallet? makeLeaderWallet(String accountId, Cipher cipher,
      {required CipherUpdate cipherUpdate, String? entropy}) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    var encryptedEntropy = EncryptedEntropy.fromEntropy(entropy, cipher);
    if (wallets.primaryIndex.getOne(encryptedEntropy.walletId) == null) {
      return LeaderWallet(
        walletId: encryptedEntropy.walletId,
        accountId: accountId,
        encryptedEntropy: encryptedEntropy.encryptedSecret,
        cipherUpdate: cipherUpdate,
      );
    }
  }

  Future<void> makeSaveLeaderWallet(String accountId, Cipher cipher,
      {required CipherUpdate cipherUpdate, String? mnemonic}) async {
    var leaderWallet = makeLeaderWallet(accountId, cipher,
        cipherUpdate: cipherUpdate,
        entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null);
    if (leaderWallet != null) {
      await wallets.save(leaderWallet);
    }
  }
}