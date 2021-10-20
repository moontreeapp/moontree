import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:raven/records/cipher.dart';
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/security/cipher_base.dart';
import 'package:raven/security/cipher_none.dart';
import 'package:raven/utils/enum.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';

part 'cipher.keys.dart';

class CipherReservoir extends Reservoir<_CipherUpdateKey, Cipher> {
  late IndexMultiple<_PasswordKey, Cipher> byPassword;
  late IndexMultiple<_CipherTypeKey, Cipher> byCipherType;
  late IndexMultiple<_CipherTypePasswordIdKey, Cipher> byCipherTypePasswordId;

  CipherReservoir() : super(_CipherUpdateKey()) {
    byPassword = addIndexMultiple('password', _PasswordKey());
    byCipherType = addIndexMultiple('cipherType', _CipherTypeKey());
    byCipherTypePasswordId =
        addIndexMultiple('cipherTypePasswordId', _CipherTypePasswordIdKey());
  }

  static Map<CipherType, Function> cipherInitializers = {
    CipherType.None: (Uint8List password) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };

  // populate with a nocipher cipher for creation of wallets without password
  static Map<CipherUpdate, Cipher> get defaults => {
        //defaultCipherUpdate: cipherInitializers[defaultCipherUpdate.cipherType]!(Uint8List(0))
        defaultCipherUpdate: Cipher(
            cipher: cipherInitializers[defaultCipherUpdate.cipherType]!(),
            cipherType: defaultCipherUpdate.cipherType,
            passwordId: defaultCipherUpdate.passwordId)
      };

  CipherBase registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    var cipher = cipherInitializers[cipherUpdate.cipherType]!(password);
    save(cipher);
    // cipher stream now produces by reservoir by defualt
    //subjects.cipher.sink.add(cipher);
    //subjects.cipherUpdate.sink.add(cipherUpdate);
    return cipher;
  }
}
