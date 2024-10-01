import 'dart:typed_data';
//import 'package:convert/convert.dart'; // If you need hex.decode
//Uint8List pubKeyBytes(String hex) => HEX.decode(pubKeyString);

Uint8List hexToBytes(String hex) => Uint8List.fromList(hexDecode(hex));

Uint8List hexDecode(String hex) => Uint8List.fromList(
    hex.split('').map((char) => int.parse(char, radix: 16)).toList());

Uint8List hexToBytesPubkey(String hex) {
  final result = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    final byte = hex.substring(i, i + 2);
    result.add(int.parse(byte, radix: 16));
  }
  return Uint8List.fromList(result);
}
