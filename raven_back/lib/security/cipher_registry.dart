import 'dart:typed_data';

import 'package:raven/records/cipher_type.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/security/cipher.dart';
import 'package:raven/security/cipher_none.dart';
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';
import 'cipher.dart';

class CipherRegistry {
  final Map<CipherUpdate, Cipher> ciphers = {};
  static CipherType latestCipherType =
      services.passwords.required ? CipherType.AES : CipherType.None;
  final Map<CipherType, Function> cipherInitializers = {
    CipherType.None: (Uint8List password) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };

  CipherRegistry() {
    // populate with a nocipher cipher for creation of wallets without password
    registerCipher(defaultCipherUpdate, Uint8List(0));
  }

  @override
  String toString() =>
      'ciphers: $ciphers, latestCipherType: ${describeEnum(latestCipherType)}';

  CipherType get getLatestCipherType => CipherRegistry.latestCipherType;

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwordId: passwords.maxPasswordId);

  Cipher? get currentCipher => ciphers[currentCipherUpdate];

  void initCiphers({
    Uint8List? password,
    String? altPassword,
    Set<CipherUpdate>? currentCipherUpdates,
  }) {
    password = getPassword(password: password, altPassword: altPassword);
    for (var currentCipherUpdate in currentCipherUpdates ?? cipherUpdates) {
      registerCipher(currentCipherUpdate, password);
    }
  }

  Uint8List getPassword({Uint8List? password, String? altPassword}) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize ciphers.'))();
    return password ?? Uint8List.fromList(altPassword!.codeUnits);
  }

  void updatePassword({
    Uint8List? password,
    String? altPassword,
    CipherType? latest,
  }) {
    latest = latest ?? latestCipherType;
    password = getPassword(password: password, altPassword: altPassword);
    registerCipher(
        CipherUpdate(latest, passwordId: passwords.maxPasswordId), password);
  }

  Cipher registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    var cipher = cipherInitializers[cipherUpdate.cipherType]!(password);
    ciphers[cipherUpdate] = cipher;
    subjects.cipher.sink.add(cipher);
    subjects.cipherUpdate.sink.add(cipherUpdate);
    return ciphers[cipherUpdate]!;
  }

  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets() async {
    var records = <Wallet>[];
    for (var wallet in wallets.data) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          /// what if wallet has never been encrypted?
          /// that will be the case on brand new wallets first time you open the app.
          var reencrypt = EncryptedEntropy.fromEntropy(
            EncryptedEntropy(wallet.encrypted, wallet.cipher!).entropy,
            ciphers[currentCipherUpdate]!,
          );
          assert(wallet.walletId == reencrypt.walletId);
          // these should be different...
          records.add(LeaderWallet(
            walletId: reencrypt.walletId,
            accountId: wallet.accountId,
            encryptedEntropy: reencrypt.encryptedSecret,
            cipherUpdate: currentCipherUpdate,
          ));
        } else if (wallet is SingleWallet) {
          var reencrypt = EncryptedWIF.fromWIF(
            EncryptedWIF(wallet.encrypted, wallet.cipher!).wif,
            ciphers[currentCipherUpdate]!,
          );
          assert(wallet.walletId == reencrypt.walletId);
          records.add(SingleWallet(
            walletId: reencrypt.walletId,
            accountId: wallet.accountId,
            encryptedWIF: reencrypt.encryptedSecret,
            cipherUpdate: currentCipherUpdate,
          ));
        }
      }
    }
    await wallets.saveAll(records);

    /// completed successfully
    //assert(services.wallets.getPreviousCipherUpdates.isEmpty);
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses and that are not the current one
  void cleanupCiphers() {
    ciphers.removeWhere((key, value) => !cipherUpdates.contains(key));
    if (ciphers.length > 1) {
      // in theory a wallet is not updated ... error?
      print('no ciphers - that is weird');
    }
  }

  Set<CipherUpdate> get cipherUpdates =>
      (services.wallets.getAllCipherUpdates.toList() + [currentCipherUpdate])
          .toSet();
}
