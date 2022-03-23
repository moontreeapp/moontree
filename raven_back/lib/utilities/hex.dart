import 'dart:typed_data';

import 'package:raven_back/security/cipher_base.dart';
import 'package:convert/convert.dart';

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

String encrypt(String hexString, CipherBase cipher) =>
    encode(cipher.encrypt(decode(hexString)));

String decrypt(String hexString, CipherBase cipher) =>
    encode(cipher.decrypt(decode(hexString)));

String toHexString(String string) => hex.encode(string.codeUnits);

String hexToAscii(String hexString) => List.generate(
      hexString.length ~/ 2,
      (i) => String.fromCharCode(
          int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
    ).join();
