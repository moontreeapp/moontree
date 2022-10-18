import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ravencoin_back/security/cipher_aes.dart';
import 'package:ravencoin_back/security/cipher_base.dart';
import 'package:ravencoin_back/security/cipher_none.dart';
import 'package:proclaim/proclaim.dart';

import 'package:ravencoin_back/records/records.dart';

part 'cipher.keys.dart';

class CipherProclaim extends Proclaim<_IdKey, Cipher> {
  late IndexMultiple<_PasswordKey, Cipher> byPassword;
  late IndexMultiple<_CipherTypeKey, Cipher> byCipherType;

  CipherProclaim() : super(_IdKey()) {
    byPassword = addIndexMultiple('password', _PasswordKey());
    byCipherType = addIndexMultiple('cipherType', _CipherTypeKey());
  }

  // populate with a nocipher cipher for creation of wallets without password
  static Map<String, Cipher> get defaults => {
        defaultCipherUpdate.cipherUpdateId: Cipher(
            cipher: cipherInitializers[defaultCipherUpdate.cipherType]!(),
            cipherType: defaultCipherUpdate.cipherType,
            passwordId: defaultCipherUpdate.passwordId)
      };

  static Map<CipherType, Function> cipherInitializers = {
    CipherType.none: ([Uint8List? password, Uint8List? salt]) => CipherNone(),
    CipherType.aes: (Uint8List password, [Uint8List? salt]) =>
        CipherAES(password, salt: salt),
  };

  CipherBase registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
    Uint8List salt,
  ) {
    var cipher = cipherInitializers[cipherUpdate.cipherType]!(password, salt);
    save(Cipher(
        cipherType: cipherUpdate.cipherType,
        passwordId: cipherUpdate.passwordId,
        cipher: cipher));
    return cipher;
  }
}
