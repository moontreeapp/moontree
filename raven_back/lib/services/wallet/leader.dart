import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/security/cipher_base.dart';
import 'package:raven/security/encrypted_entropy.dart';
import 'package:raven/utils/seed_wallet.dart';
import 'package:raven/raven.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  /// [Address(walletid=0...),]
  Future<List<Address>> maybeDeriveNewAddresses(
      List<Address> changedAddresses) async {
    var remaining = <Address>[];
    for (var address in changedAddresses) {
      var leaderWallet =
          wallets.primaryIndex.getOne(address.walletId)! as LeaderWallet;
      if (ciphers.primaryIndex.getOne(leaderWallet.cipherUpdate) != null) {
        maybeSaveNewAddress(
            leaderWallet,
            ciphers.primaryIndex.getOne(leaderWallet.cipherUpdate)!.cipher,
            NodeExposure.Internal);
        maybeSaveNewAddress(
            leaderWallet,
            ciphers.primaryIndex.getOne(leaderWallet.cipherUpdate)!.cipher,
            NodeExposure.External);
      } else {
        remaining.add(address);
      }
    }
    return remaining;
  }

  void maybeSaveNewAddress(
      LeaderWallet leaderWallet, CipherBase cipher, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet, cipher, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) {
    var gap = 0;
    var exposureAddresses =
        addresses.byWalletExposure.getAll(leaderWallet.walletId, exposure);
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (vins.byScripthash.getAll(exposureAddress.addressId).isEmpty ? 1 : 0);
    }
    if (gap < 10) {
      return deriveAddress(leaderWallet, exposureAddresses.length,
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
    int hdIndex, {
    exposure = NodeExposure.External,
  }) {
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

  void deriveFirstAddressAndSave(LeaderWallet wallet) {
    var addrInt = deriveAddress(wallet, 0, exposure: NodeExposure.Internal);
    addresses.save(addrInt);
    var addrExt = deriveAddress(wallet, 0, exposure: NodeExposure.External);
    addresses.save(addrExt);
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(LeaderWallet leaderWallet,
      {NodeExposure exposure = NodeExposure.Internal}) {
    var seedWallet = getSeedWallet(leaderWallet);
    var i = 0;
    while (true) {
      var hdWallet = seedWallet.subwallet(i, exposure: exposure);
      if (vins.byScripthash.getAll(hdWallet.scripthash).isEmpty) {
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

  void maybeSaveNewAddresses(
      LeaderWallet leaderWallet, CipherBase cipher, NodeExposure exposure) {
    for (var newAddress
        in maybeDeriveNextAddresses(leaderWallet, cipher, exposure)) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  List<Address> maybeDeriveNextAddresses(
    LeaderWallet leaderWallet,
    CipherBase cipher,
    NodeExposure exposure,
  ) {
    var gap = 0;
    var exposureAddresses =
        addresses.byWalletExposure.getAll(leaderWallet.walletId, exposure);
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (vins.byScripthash.getAll(exposureAddress.addressId).isEmpty ? 1 : 0);
    }
    if (gap < 10) {
      return [
        for (var i = 0; i < 10 - gap; i++)
          deriveAddress(leaderWallet, exposureAddresses.length + i,
              exposure: exposure)
      ];
    }
    return [];
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);
}
