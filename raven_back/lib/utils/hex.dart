import 'dart:typed_data';

import 'package:convert/convert.dart';

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

typedef String2StringFn = String Function(String);
typedef U8List2U8ListFn = Uint8List Function(Uint8List);

/// Given a function that takes Uint8List and returns Uint8List, convert it
/// to a function that takes (hex encoded) String and returns (hex encoded)
/// String.
String2StringFn chainU8toS(U8List2U8ListFn fn) =>
    (String input) => encode(fn(decode(input)));


// Intended behavior, e.g.:
// var newEncrypt = chainU8toS(cipher.encrypt); // String newEncrypt(String)
// var newDecrypt = chainU8toS(cipher.decrypt); // String newDecript(String)

