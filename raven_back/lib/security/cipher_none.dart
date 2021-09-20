import 'dart:typed_data';

import 'cipher.dart';

class CipherNone implements Cipher {
  const CipherNone();

  @override
  Uint8List encrypt(Uint8List plainText) => plainText;

  @override
  Uint8List decrypt(Uint8List cipherText) => cipherText;
}
