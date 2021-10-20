import 'dart:typed_data';

import 'package:raven/records/cipher_type.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/security/cipher_base.dart';
import 'package:raven/security/cipher_none.dart';
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/utils/enum.dart';
import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';
import 'cipher_base.dart';

class CipherRegistry {
  final Map<CipherUpdate, CipherBase> ciphers = {};
  final Map<CipherType, Function> cipherInitializers = {
    CipherType.None: (Uint8List password) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };

  CipherRegistry() {
    // populate with a nocipher cipher for creation of wallets without password
    registerCipher(defaultCipherUpdate, Uint8List(0));
  }

  CipherBase registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    var cipher = cipherInitializers[cipherUpdate.cipherType]!(password);
    ciphers[cipherUpdate] = cipher;
    subjects.cipher.sink.add(cipher);
    subjects.cipherUpdate.sink.add(cipherUpdate);
    return ciphers[cipherUpdate]!;
  }
}
