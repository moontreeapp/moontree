import 'dart:typed_data';
import 'package:pointycastle/export.dart';

Uint8List getBytes(String key) => Uint8List.fromList(key.codeUnits);

// AES initialization vector; must be 16 bytes
Uint8List defaultInitializationVector = getBytes('aeree5Zaeveexooj');

class Cipher {
  final Uint8List _key;
  final Uint8List _iv;

  Cipher(Uint8List key, {Uint8List? iv})
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

  Uint8List encrypt(Uint8List plainText) {
    return cipher(true).process(plainText);
  }

  Uint8List decrypt(Uint8List cipherText) {
    return cipher(false).process(cipherText);
  }
}

// contained in accounts - making here so no relative imports issue in boxes.
Cipher CIPHER = Cipher(Uint8List.fromList(
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]));
