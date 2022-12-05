import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/security/cipher_aes.dart';
import 'package:ravencoin_back/security/cipher_base.dart';
import 'package:ravencoin_back/security/cipher_none.dart';

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
  static Map<String, Cipher> get defaults => <String, Cipher>{
        defaultCipherUpdate.cipherUpdateId: Cipher(
            cipher: CipherProclaim.initializersCipher(
                defaultCipherUpdate.cipherType),
            cipherType: defaultCipherUpdate.cipherType,
            passwordId: defaultCipherUpdate.passwordId)
      };

  static Map<CipherType, Function> cipherInitializers =
      <CipherType, CipherBase Function(Uint8List)>{
    CipherType.none: ([Uint8List? password, Uint8List? salt]) =>
        const CipherNone(),
    CipherType.aes: (Uint8List password, [Uint8List? salt]) =>
        CipherAES(password, salt: salt),
  };
  static CipherBase initializersCipher(
    CipherType cipherType, [
    Uint8List? password,
    Uint8List? salt,
  ]) {
    switch (cipherType) {
      case CipherType.none:
        return const CipherNone();
      case CipherType.aes:
        if (password == null) {
          throw Exception('cannot initialize AES cipher without password');
        }
        return CipherAES(password, salt: salt);
    }
  }

  CipherBase registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
    Uint8List salt,
  ) {
    final CipherBase cipher = CipherProclaim.initializersCipher(
      cipherUpdate.cipherType,
      password,
      salt,
    );
    save(Cipher(
        cipherType: cipherUpdate.cipherType,
        passwordId: cipherUpdate.passwordId,
        cipher: cipher));
    return cipher;
  }
}
