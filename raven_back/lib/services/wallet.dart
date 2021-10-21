import 'package:ravencoin/ravencoin.dart' show ECPair, WalletBase;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/raven.dart';

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
      wallets.data.map((wallet) => wallet.cipherUpdate).toSet();

  // should return cipherUpdates that must be used with current password...
  Set<CipherUpdate> get getCurrentCipherUpdates => wallets.data
      .map((wallet) => wallet.cipherUpdate)
      .where(
          (cipherUpdate) => cipherUpdate.passwordId == passwords.maxPasswordId)
      .toSet();

  // should return cipherUpdates that must be used with previous password...
  Set<CipherUpdate> get getPreviousCipherUpdates =>
      passwords.maxPasswordId == null
          ? {}
          : wallets.data
              .map((wallet) => wallet.cipherUpdate)
              .where((cipherUpdate) =>
                  cipherUpdate.cipherType != CipherType.None &&
                  cipherUpdate.passwordId! < passwords.maxPasswordId!)
              .toSet();

  Future createSave({
    required WalletType walletType,
    required String accountId,
    required CipherUpdate cipherUpdate,
    required String secret,
  }) async =>
      {
        WalletType.leader: () async => await leader.makeSaveLeaderWallet(
              accountId,
              ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              mnemonic: secret,
            ),
        WalletType.single: () async => await single.makeSaveSingleWallet(
              accountId,
              ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              wif: secret,
            )
      }[walletType]!();

  Wallet? create({
    required WalletType walletType,
    required String accountId,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
  }) =>
      {
        WalletType.leader: () => leader.makeLeaderWallet(
              accountId,
              ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              entropy: secret != null ? bip39.mnemonicToEntropy(secret) : null,
              alwaysReturn: alwaysReturn,
            ),
        WalletType.single: () => single.makeSingleWallet(
              accountId,
              ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
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
}
