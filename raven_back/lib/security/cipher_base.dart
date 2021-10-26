import 'dart:typed_data';

import 'package:raven/utils/getBytes.dart';

const int DEFAULT_ITERATIONS = 2;
const int DEFAULT_MEMORY = 16;
final Uint8List DEFAULT_SALT = getBytes('aeree5Zaeveexooj');

abstract class CipherBase {
  Uint8List encrypt(Uint8List plainText);
  Uint8List decrypt(Uint8List cipherText);
}
