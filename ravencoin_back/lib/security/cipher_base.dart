import 'dart:typed_data';

import 'package:ravencoin_back/extensions/string.dart';

const int DEFAULT_ITERATIONS = 2;
const int DEFAULT_MEMORY = 16;
final Uint8List DEFAULT_SALT = 'aeree5Zaeveexooj'.bytesUint8;

abstract class CipherBase {
  Uint8List encrypt(Uint8List plainText);
  Uint8List decrypt(Uint8List cipherText);
}
