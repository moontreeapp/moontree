import 'dart:typed_data';

const int DEFAULT_ITERATIONS = 2;
const int DEFAULT_MEMORY = 16;
final Uint8List DEFAULT_SALT = getBytes('aeree5Zaeveexooj');

Uint8List getBytes(String key) => Uint8List.fromList(key.codeUnits);

abstract class CipherBase {
  Uint8List encrypt(Uint8List plainText);
  Uint8List decrypt(Uint8List cipherText);
}
