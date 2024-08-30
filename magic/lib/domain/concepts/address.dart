import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:bs58/bs58.dart';

Uint8List hash160FromHexString(String x) =>
    hash160(Uint8List.fromList(hex.decode(x)));

Uint8List doubleSHA256(Uint8List data) {
  final digest1 = SHA256Digest();
  final iter1 = digest1.process(data);
  final digest2 = SHA256Digest();
  return digest2.process(iter1);
}

String h160ToAddress({required Uint8List h160, required int addressType}) {
  if (h160.length != 0x14) {
    throw Exception('Invalid h160 length');
  }
  List<int> x = [];
  x.add(addressType);
  x.addAll(h160);
  x.addAll(doubleSHA256(Uint8List.fromList(x)).sublist(0, 4));
  return base58.encode(Uint8List.fromList(x));
}

Uint8List hash160(Uint8List x) {
  return RIPEMD160Digest().process(SHA256Digest().process(x));
}

Uint8List addressToH160(String address) {
  // Decode the base58 address
  Uint8List decoded = base58.decode(address);

  // Check if the decoded length is valid
  if (decoded.length != 25) {
    throw Exception('Invalid address length');
  }

  // Extract the parts
  Uint8List h160 = decoded.sublist(1, 21);
  Uint8List checksum = decoded.sublist(21);

  // Validate the checksum
  Uint8List dataToCheck = decoded.sublist(0, 21);
  Uint8List actualChecksum = doubleSHA256(dataToCheck).sublist(0, 4);

  for (int i = 0; i < checksum.length; i++) {
    if (checksum[i] != actualChecksum[i]) {
      throw Exception('Invalid checksum');
    }
  }

  return h160;
}
