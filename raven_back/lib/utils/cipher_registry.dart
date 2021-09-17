import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:raven/records/cipher_type.dart';

import 'cipher.dart';

Map<CipherVersion, Cipher> ciphers = {};

class CipherVersion with EquatableMixin {
  CipherType cipherType;
  int passwordVersion;

  CipherVersion(this.cipherType, this.passwordVersion);

  @override
  List<Object?> get props => [cipherType, passwordVersion];
}

Map<CipherType, Function> cipherInitializers = {
  CipherType.NoCipher: (Uint8List password) => NoCipher(),
  CipherType.AESCipher: (Uint8List password) => AESCipher(password),
};

void initCiphersWithPassword(List<CipherVersion> versions, Uint8List password) {
  for (var version in versions) {
    ciphers[version] = cipherInitializers[version.cipherType]!(password);
  }
}
