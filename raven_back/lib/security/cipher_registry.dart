import 'dart:typed_data';

import 'package:quiver/iterables.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/security/cipher.dart';
import 'package:raven/security/cipher_none.dart';
import 'package:raven/security/cipher_aes.dart';

import 'cipher.dart';

const latestCipherType = CipherType.AES;

Map<CipherType, Function> cipherInitializers = {
  CipherType.None: (Uint8List password) => CipherNone(),
  CipherType.AES: (Uint8List password) => CipherAES(password),
};

class CipherRegistry {
  final Map<CipherUpdate, Cipher> ciphers = {};

  CipherRegistry();

  void initCiphers(
    Set<CipherUpdate> currentCipherUpdates,
    Uint8List password,
  ) {
    for (var currentCipherUpdate in currentCipherUpdates) {
      registerCipher(currentCipherUpdate, password);
    }
  }

  int maxPasswordVersion(CipherType latest) =>
      max([
        for (var cu in ciphers.keys
            .where((cipherUpdate) => cipherUpdate.cipherType == latest)
            .toList())
          cu.passwordVersion
      ]) ??
      0;

  CipherUpdate updatePassword(Uint8List password,
      {CipherType latest = latestCipherType}) {
    var update = CipherUpdate(latest, maxPasswordVersion(latest) + 1);
    registerCipher(update, password);
    return update;
  }

  Cipher registerCipher(
    CipherUpdate cipherUpdate,
    Uint8List password,
  ) {
    var registered = cipherInitializers[cipherUpdate.cipherType]!(password);
    ciphers[cipherUpdate] = registered;
    return registered;
  }
}
