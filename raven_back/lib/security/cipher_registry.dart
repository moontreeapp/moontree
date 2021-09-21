import 'dart:typed_data';

import 'package:quiver/iterables.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/security/cipher.dart';
import 'package:raven/security/cipher_none.dart';
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/utils/exceptions.dart';

import 'cipher.dart';

class CipherRegistry {
  final Map<CipherUpdate, Cipher> ciphers = {};
  static const latestCipherType = CipherType.AES;
  final Map<CipherType, Function> cipherInitializers = {
    CipherType.None: (Uint8List password) => CipherNone(),
    CipherType.AES: (Uint8List password) => CipherAES(password),
  };

  CipherRegistry();

  Cipher get currentCipher => ciphers[currentCipherUpdate]!;

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, maxPasswordVersion(latestCipherType));

  void initCiphers(
    Set<CipherUpdate> currentCipherUpdates, {
    Uint8List? password,
    String? altPassword,
  }) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize ciphers.'))();
    password = password ?? Uint8List.fromList(altPassword!.codeUnits);
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
    ciphers[cipherUpdate] =
        cipherInitializers[cipherUpdate.cipherType]!(password);
    return ciphers[cipherUpdate]!;
  }
}
