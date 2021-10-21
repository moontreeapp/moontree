import 'dart:typed_data';

import 'package:raven/raven.dart';
import 'package:raven/utils/enum.dart';

class CipherService {
  static CipherType latestCipherType =
      services.password.required ? CipherType.AES : CipherType.None;
  @override
  String toString() => 'latestCipherType: ${describeEnum(latestCipherType)}';

  CipherType get getLatestCipherType => latestCipherType;

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwordId: passwords.maxPasswordId);

  CipherBase? get currentCipher =>
      ciphers.primaryIndex.getOne(currentCipherUpdate)!.cipher;

  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets() async {
    var records = <Wallet>[];
    for (var wallet in wallets.data) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          records.add(reencryptLeaderWallet(wallet));
        } else if (wallet is SingleWallet) {
          records.add(reencryptSingleWallet(wallet));
        }
      }
    }
    await wallets.saveAll(records);

    /// completed successfully
    assert(services.wallet.getPreviousCipherUpdates.isEmpty);
  }

  LeaderWallet reencryptLeaderWallet(LeaderWallet wallet) {
    var reencrypt = EncryptedEntropy.fromEntropy(
      EncryptedEntropy(wallet.encrypted, wallet.cipher!).entropy,
      currentCipher!,
    );
    assert(wallet.walletId == reencrypt.walletId);
    return LeaderWallet(
      walletId: reencrypt.walletId,
      accountId: wallet.accountId,
      encryptedEntropy: reencrypt.encryptedSecret,
      cipherUpdate: currentCipherUpdate,
    );
  }

  SingleWallet reencryptSingleWallet(SingleWallet wallet) {
    var reencrypt = EncryptedWIF.fromWIF(
      EncryptedWIF(wallet.encrypted, wallet.cipher!).wif,
      currentCipher!,
    );
    assert(wallet.walletId == reencrypt.walletId);
    return SingleWallet(
      walletId: reencrypt.walletId,
      accountId: wallet.accountId,
      encryptedWIF: reencrypt.encryptedSecret,
      cipherUpdate: currentCipherUpdate,
    );
  }

  void initCiphers({
    Uint8List? password,
    String? altPassword,
    Set<CipherUpdate>? currentCipherUpdates,
  }) {
    password = _getPassword(password: password, altPassword: altPassword);
    for (var currentCipherUpdate in currentCipherUpdates ?? _cipherUpdates) {
      ciphers.registerCipher(currentCipherUpdate, password);
    }
  }

  void updatePassword({
    Uint8List? password,
    String? altPassword,
    CipherType? latest,
  }) {
    latest = latest ?? latestCipherType;
    password = _getPassword(password: password, altPassword: altPassword);
    ciphers.registerCipher(
        CipherUpdate(latest, passwordId: passwords.maxPasswordId), password);
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses and that are not the current one
  void cleanupCiphers() {
    ciphers.removeAll(ciphers.data
        .where((cipher) => !_cipherUpdates.contains(cipher.cipherUpdate)));
    if (ciphers.data.length > 1) {
      // in theory a wallet is not updated ... error?
      print('no ciphers - that is weird');
    }
  }

  Set<CipherUpdate> get _cipherUpdates =>
      (services.wallet.getAllCipherUpdates.toList() + [currentCipherUpdate])
          .toSet();

  Uint8List _getPassword({Uint8List? password, String? altPassword}) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize ciphers.'))();
    return password ?? Uint8List.fromList(altPassword!.codeUnits);
  }
}
