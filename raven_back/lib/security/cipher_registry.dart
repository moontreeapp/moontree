import 'dart:typed_data';

import 'package:quiver/iterables.dart';
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
  static const latestCipherType = CipherType.AES;
  final Map<CipherType, Function> cipherInitializers = {
    CipherType.None: (Uint8List password) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };
  static const defaultCipherUpdate = CipherUpdate(CipherType.None, -1);

  CipherRegistry() {
    registerCipher(defaultCipherUpdate, Uint8List(0));
  }

  @override
  String toString() =>
      'ciphers: $ciphers, latestCipherType: ${describeEnum(latestCipherType)}';

  CipherType get getLatestCipherType => CipherRegistry.latestCipherType;

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwords.maxPasswordID);

  Cipher get currentCipher => ciphers[currentCipherUpdate]!;
  // this is it. we need to produce the cipher before login on mock data. (because accounts waiter uses it.)
  //ciphers[currentCipherUpdate] ?? ciphers[defaultCipherUpdate]!;
  // passworded ciphers might not be instaneated yet
  //passwords.maxPasswordID > -1
  //    ? ciphers[currentCipherUpdate]!
  //    : ciphers[defaultCipherUpdate]!;

  void initCiphers(
    Set<CipherUpdate> currentCipherUpdates, {
    Uint8List? password,
    String? altPassword,
  }) {
    password = getPassword(password: password, altPassword: altPassword);
    print('using password: $password');
    print(currentCipherUpdates);
    for (var currentCipherUpdate in currentCipherUpdates) {
      var registered = registerCipher(currentCipherUpdate, password);
      print('registered $registered');
    }
  }

  Uint8List getPassword({Uint8List? password, String? altPassword}) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize ciphers.'))();
    return password ?? Uint8List.fromList(altPassword!.codeUnits);
  }

  void updatePassword(
      {Uint8List? password,
      String? altPassword,
      CipherType latest = latestCipherType}) {
    password = getPassword(password: password, altPassword: altPassword);
    registerCipher(CipherUpdate(latest, passwords.maxPasswordID), password);
  }

  Cipher registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    print('registering $cipherUpdate');
    ciphers[cipherUpdate] =
        cipherInitializers[cipherUpdate.cipherType]!(password);
    return ciphers[cipherUpdate]!;
  }

  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets() async {
    print('somehow wallets are not being saved with the new passwordId...');
    print(currentCipherUpdate);
    var records = <Wallet>[];
    for (var wallet in wallets.data) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        print('wallet not updated:');
        print(wallet);
        print(currentCipherUpdate);
        print(wallet.cipherUpdate);
        print(currentCipherUpdate != wallet.cipherUpdate);
        if (wallet is LeaderWallet) {
          /// what if wallet has never been encrypted?
          /// that will be the case on brand new wallets first time you open the app.
          var reencrypt = EncryptedEntropy.fromEntropy(
            EncryptedEntropy(wallet.encrypted, wallet.cipher!).entropy,
            ciphers[currentCipherUpdate]!,
          );
          assert(wallet.walletId == reencrypt.walletId);
          // these should be different...
          print(reencrypt);
          print(EncryptedEntropy(wallet.encrypted, wallet.cipher!));
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

    /// somehow the wallets.save isn't saving correctly, it's getting passed the right stuff..
    /// are we mutating a local copy?
    print('WALLETS.DATA: ${wallets.data}');

    /// it was due to props on wallets - not distinguishing the change when saving new encryptedEntropty

    /// completed successfully
    //assert(services.wallets.getPreviousCipherUpdates.isEmpty);
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses
  void cleanupCiphers() {
    var walletCipherUpdates = services.wallets.getAllCipherUpdates;
    ciphers.removeWhere((key, value) => !walletCipherUpdates.contains(key));
    if (ciphers.length > 1) {
      // in theory a wallet is not updated ... error?
    }
  }
}
