import 'dart:typed_data';

import 'package:raven/raven.dart';
import 'package:raven/utils/enum.dart';

class CipherService {
  /// used in decrypting backups - we don't know what cipher it was encrypted with... we could save it...
  List<CipherType> get allCipherTypes => [CipherType.AES, CipherType.None];

  CipherType get latestCipherType =>
      services.password.exist ? CipherType.AES : CipherType.None;

  @override
  String toString() => 'latestCipherType: ${describeEnum(latestCipherType)}';

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwordId: passwords.maxPasswordId);

  // TODO: change this to currentCipherBase
  CipherBase? get currentCipher => currentCipher2?.cipher;

  Cipher? get currentCipher2 =>
      ciphers.primaryIndex.getOne(currentCipherUpdate);

  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets({CipherBase? cipher}) async {
    var records = <Wallet>[];
    for (var wallet in wallets.data) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          records.add(reencryptLeaderWallet(wallet, cipher));
        } else if (wallet is SingleWallet) {
          records.add(reencryptSingleWallet(wallet, cipher));
        }
      }
    }
    await wallets.saveAll(records);

    /// completed successfully
    assert(services.wallet.getPreviousCipherUpdates.isEmpty);
  }

  LeaderWallet reencryptLeaderWallet(LeaderWallet wallet,
      [CipherBase? cipher]) {
    var reencrypt = EncryptedEntropy.fromEntropy(
      EncryptedEntropy(wallet.encrypted, wallet.cipher!).entropy,
      cipher ?? currentCipher!,
    );
    assert(wallet.walletId == reencrypt.walletId);
    return LeaderWallet(
      walletId: reencrypt.walletId,
      accountId: wallet.accountId,
      encryptedEntropy: reencrypt.encryptedSecret,
      cipherUpdate: currentCipherUpdate,
    );
  }

  SingleWallet reencryptSingleWallet(SingleWallet wallet,
      [CipherBase? cipher]) {
    var reencrypt = EncryptedWIF.fromWIF(
      EncryptedWIF(wallet.encrypted, wallet.cipher!).wif,
      cipher ?? currentCipher!,
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
    password = getPassword(password: password, altPassword: altPassword);
    for (var currentCipherUpdate in currentCipherUpdates ?? _cipherUpdates) {
      ciphers.registerCipher(currentCipherUpdate, password);
    }
  }

  CipherBase updatePassword({
    Uint8List? password,
    String? altPassword,
    CipherType? latest,
  }) {
    latest = latest ?? latestCipherType;
    password = getPassword(password: password, altPassword: altPassword);
    return ciphers.registerCipher(
      //CipherUpdate(latest, passwordId: passwords.maxPasswordId),
      currentCipherUpdate,
      password,
    );
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses and that are not the current one
  void cleanupCiphers() {
    ciphers.removeAll(ciphers.data
        .where((cipher) => !_cipherUpdates.contains(cipher.cipherUpdate)));

    if (ciphers.data.length > 2) {
      // in theory a wallet is not updated ... error?
      print('more ciphers than default and password - that is weird');
    }
  }

  Set<CipherUpdate> get _cipherUpdates =>
      (services.wallet.getAllCipherUpdates.toList() + [currentCipherUpdate])
          .toSet();

  Uint8List getPassword({Uint8List? password, String? altPassword}) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize ciphers.'))();
    return password ?? Uint8List.fromList(altPassword!.codeUnits);
  }
}
