import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/utils/seed_wallet.dart';
import 'package:raven/raven.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final requiredGap = 2;

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

  /// this function is used to determine if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Set<Address> maybeDeriveNextAddresses(
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
    var newAddresses = {
      for (var i = 0; i < requiredGap - currentGap; i++)
        deriveAddress(leaderWallet, usedCount + i, exposure: exposure)
    };
    if (leaderWallet.walletId ==
        '03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342') {
      print('exposure, $exposure');
      print('usedCount $usedCount');
      print('currentGap $currentGap');
      print('newAddresses ${newAddresses.map((a) => a.address)}');
      //if (exposure == NodeExposure.Internal) {
      //  print(leaderWallet.emptyInternalAddresses);
      //}
    }
    return newAddresses;
  }

  HDWallet getChangeWallet(LeaderWallet wallet) => getNextEmptyWallet(wallet);
}
