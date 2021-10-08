import 'package:ravencoin/ravencoin.dart' show ECPair;

import 'package:raven/utils/transform.dart';
import 'package:raven/raven.dart';

import 'wallet/leader.dart';
import 'wallet/single.dart';

class WalletService {
  final LeaderWalletService leaders = LeaderWalletService();
  final SingleWalletService singles = SingleWalletService();

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
    required LingoKey humanTypeKey,
    required String accountId,
    required CipherUpdate cipherUpdate,
    required String secret,
  }) async =>
      {
        LeaderWallet: () async => await leaders.makeSaveLeaderWallet(
            accountId, cipherRegistry.ciphers[cipherUpdate]!,
            cipherUpdate: cipherUpdate, mnemonic: secret),
        SingleWallet: () async => await singles.makeSaveSingleWallet(
            accountId, cipherRegistry.ciphers[cipherUpdate]!,
            cipherUpdate: cipherUpdate, wif: secret)
      }[walletType(humanTypeKey)]!();

  Map walletMap() => {
        LeaderWallet: LingoKey.leaderWalletType,
        SingleWallet: LingoKey.singleWalletType
      };

  Type walletType(LingoKey humanTypeKey) =>
      reverseMap(walletMap())[humanTypeKey] ?? Wallet;

  ECPair getAddressKeypair(Address address) {
    var wallet = address.wallet!;

    if (wallet is LeaderWallet) {
      var seedWallet = services.wallets.leaders.getSeedWallet(wallet);
      var hdWallet =
          seedWallet.subwallet(address.hdIndex, exposure: address.exposure);
      return hdWallet.keyPair;
    } else if (wallet is SingleWallet) {
      var kpWallet = services.wallets.singles.getKPWallet(wallet);
      return kpWallet.keyPair;
    } else {
      throw ArgumentError('wallet type unknown');
    }
  }
}
