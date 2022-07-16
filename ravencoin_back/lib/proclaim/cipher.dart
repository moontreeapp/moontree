import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ravencoin_back/security/cipher_aes.dart';
import 'package:ravencoin_back/security/cipher_base.dart';
import 'package:ravencoin_back/security/cipher_none.dart';
import 'package:ravencoin_back/extensions/object.dart';
import 'package:proclaim/proclaim.dart';

import 'package:ravencoin_back/records/records.dart';

part 'cipher.keys.dart';

class CipherProclaim extends Proclaim<_CipherUpdateKey, Cipher> {
  late IndexMultiple<_PasswordKey, Cipher> byPassword;
  late IndexMultiple<_CipherTypeKey, Cipher> byCipherType;
  late IndexMultiple<_CipherTypePasswordIdKey, Cipher> byCipherTypePasswordId;

  CipherProclaim() : super(_CipherUpdateKey()) {
    byPassword = addIndexMultiple('password', _PasswordKey());
    byCipherType = addIndexMultiple('cipherType', _CipherTypeKey());
    byCipherTypePasswordId =
        addIndexMultiple('cipherTypePasswordId', _CipherTypePasswordIdKey());
  }

  // populate with a nocipher cipher for creation of wallets without password
  static Map<String, Cipher> get defaults => {
        defaultCipherUpdate.cipherUpdateId: Cipher(
            cipher: cipherInitializers[defaultCipherUpdate.cipherType]!(),
            cipherType: defaultCipherUpdate.cipherType,
            passwordId: defaultCipherUpdate.passwordId)
      };

  static Map<CipherType, Function> cipherInitializers = {
    CipherType.None: ([Uint8List? password]) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };

  CipherBase registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    var cipher = cipherInitializers[cipherUpdate.cipherType]!(password);
    save(Cipher(
        cipherType: cipherUpdate.cipherType,
        passwordId: cipherUpdate.passwordId,
        cipher: cipher));
    return cipher;
  }
}
