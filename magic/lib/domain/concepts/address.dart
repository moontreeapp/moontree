import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:bs58/bs58.dart';

Uint8List hash160FromHexString(String x) =>
    hash160(Uint8List.fromList(hex.decode(x)));

String h160ToAddress({required Uint8List h160, required int addressType}) {
  Uint8List doubleSHA256(Uint8List data) {
    final digest1 = SHA256Digest();
    final iter1 = digest1.process(data);
    final digest2 = SHA256Digest();
    return digest2.process(iter1);
  }

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
