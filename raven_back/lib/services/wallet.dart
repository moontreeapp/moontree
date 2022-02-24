import 'package:ravencoin_wallet/ravencoin_wallet.dart' show ECPair, WalletBase;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_back/raven_back.dart';

import 'wallet/leader.dart';
import 'wallet/single.dart';
import 'wallet/export.dart';
import 'wallet/import.dart';
import 'wallet/constants.dart';

class WalletService {
  final LeaderWalletService leader = LeaderWalletService();
  final SingleWalletService single = SingleWalletService();
  final ExportWalletService export = ExportWalletService();
  final ImportWalletService import = ImportWalletService();

  // should return all cipherUpdates
  Set<CipherUpdate> get getAllCipherUpdates =>
      res.wallets.data.map((wallet) => wallet.cipherUpdate).toSet();

  // should return cipherUpdates that must be used with current password...
  Set<CipherUpdate> get getCurrentCipherUpdates => res.wallets.data
      .map((wallet) => wallet.cipherUpdate)
      .where((cipherUpdate) =>
          cipherUpdate.passwordId == res.passwords.maxPasswordId)
      .toSet();

  // should return cipherUpdates that must be used with previous password...
  Set<CipherUpdate> get getPreviousCipherUpdates =>
      res.passwords.maxPasswordId == null
          ? {}
          : res.wallets.data
              .map((wallet) => wallet.cipherUpdate)
              .where((cipherUpdate) =>
                  cipherUpdate.cipherType != CipherType.None &&
                  cipherUpdate.passwordId! < res.passwords.maxPasswordId!)
              .toSet();

  Future createSave({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String secret,
  }) async =>
      {
        WalletType.leader: () async => await leader.makeSaveLeaderWallet(
              res.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              mnemonic: secret,
            ),
        WalletType.single: () async => await single.makeSaveSingleWallet(
              res.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              wif: secret,
            )
      }[walletType]!();

  Wallet? create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
  }) =>
      {
        WalletType.leader: () => leader.makeLeaderWallet(
              res.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              entropy: secret != null ? bip39.mnemonicToEntropy(secret) : null,
              alwaysReturn: alwaysReturn,
            ),
        WalletType.single: () => single.makeSingleWallet(
              res.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              wif: secret,
              alwaysReturn: alwaysReturn,
            )
      }[walletType]!();

  ECPair getAddressKeypair(Address address) {
    var wallet = address.wallet!;
    if (wallet is LeaderWallet) {
      var seedWallet = services.wallet.leader.getSeedWallet(wallet);
      var hdWallet =
          seedWallet.subwallet(address.hdIndex, exposure: address.exposure);
      return hdWallet.keyPair;
    } else if (wallet is SingleWallet) {
      var kpWallet = services.wallet.single.getKPWallet(wallet);
      return kpWallet.keyPair;
    } else {
      throw ArgumentError('wallet type unknown');
    }
  }

  WalletBase getChangeWallet(Wallet wallet) {
    if (wallet is LeaderWallet) {
      return leader.getNextEmptyWallet(wallet);
    }
    if (wallet is SingleWallet) {
      return single.getKPWallet(wallet);
    }
    throw WalletMissing("Wallet '${wallet.walletId}' has no change wallets");
  }

  WalletBase getEmptyWallet(Wallet wallet) {
    if (wallet is LeaderWallet) {
      return leader.getNextEmptyWallet(wallet, exposure: NodeExposure.External);
    }
    if (wallet is SingleWallet) {
      return single.getKPWallet(wallet);
    }
    throw WalletMissing("Wallet '${wallet.walletId}' has no change wallets");
  }
}
