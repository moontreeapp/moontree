import 'dart:typed_data';

import 'package:raven/security/cipher.dart';
import 'package:convert/convert.dart';

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

String encrypt(String hexString, Cipher cipher) =>
    encode(cipher.encrypt(decode(hexString)));

String decrypt(String hexString, Cipher cipher) =>
    encode(cipher.decrypt(decode(hexString)));
