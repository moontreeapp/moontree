import 'dart:typed_data';
import 'package:pointycastle/export.dart';

Uint8List getBytes(String key) => Uint8List.fromList(key.codeUnits);

// AES initialization vector; must be 16 bytes
Uint8List defaultInitializationVector = getBytes('aeree5Zaeveexooj');

abstract class Cipher {
  Cipher();

  Uint8List encrypt(Uint8List plainText);
  Uint8List decrypt(Uint8List cipherText);
}

class NoCipher implements Cipher {
  const NoCipher();

  @override
  Uint8List encrypt(Uint8List plainText) => plainText;
  @override
  Uint8List decrypt(Uint8List cipherText) => cipherText;
}

class AESCipher implements Cipher {
  final Uint8List _key;
  final Uint8List _iv;

  AESCipher(Uint8List key, {Uint8List? iv})
      : _key = key,
        _iv = iv ?? defaultInitializationVector;

  PaddedBlockCipherImpl cipher(encrypt) {
    var blockCipher = CBCBlockCipher(AESFastEngine());
    var params = ParametersWithIV<KeyParameter>(KeyParameter(_key), _iv);
    var paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            params, null);
    return PaddedBlockCipherImpl(PKCS7Padding(), blockCipher)
      ..init(encrypt, paddingParams);
  }

  @override
  Uint8List encrypt(Uint8List plainText) {
    return cipher(true).process(plainText);
  }

  @override
  Uint8List decrypt(Uint8List cipherText) {
    return cipher(false).process(cipherText);
  }
}