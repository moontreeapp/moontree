import 'dart:typed_data';
import 'package:moontree_utils/types/cipher_base.dart';

class CipherNone implements CipherBase {
  const CipherNone();

  @override
  Uint8List encrypt(Uint8List plainText) => plainText;

  @override
  Uint8List decrypt(Uint8List cipherText) => cipherText;
}
