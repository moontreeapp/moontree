import 'package:raven/raven.dart';

class CipherService {
  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets() async {
    var records = <Wallet>[];
    for (var wallet in wallets.data) {
      if (wallet.cipherUpdate != cipherRegistry.currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          records.add(reencryptLeaderWallet(wallet));
        } else if (wallet is SingleWallet) {
          records.add(reencryptSingleWallet(wallet));
        }
      }
    }
    await wallets.saveAll(records);

    /// completed successfully
    assert(services.wallets.getPreviousCipherUpdates.isEmpty);
  }

  LeaderWallet reencryptLeaderWallet(LeaderWallet wallet) {
    var reencrypt = EncryptedEntropy.fromEntropy(
      EncryptedEntropy(wallet.encrypted, wallet.cipher!).entropy,
      cipherRegistry.currentCipher!,
    );
    assert(wallet.walletId == reencrypt.walletId);
    return LeaderWallet(
      walletId: reencrypt.walletId,
      accountId: wallet.accountId,
      encryptedEntropy: reencrypt.encryptedSecret,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
    );
  }

  SingleWallet reencryptSingleWallet(SingleWallet wallet) {
    var reencrypt = EncryptedWIF.fromWIF(
      EncryptedWIF(wallet.encrypted, wallet.cipher!).wif,
      cipherRegistry.currentCipher!,
    );
    assert(wallet.walletId == reencrypt.walletId);
    return SingleWallet(
      walletId: reencrypt.walletId,
      accountId: wallet.accountId,
      encryptedWIF: reencrypt.encryptedSecret,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
    );
  }
}
