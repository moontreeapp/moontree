import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:bs58/bs58.dart' as bs58;

enum BASE { base32, base58 }

Uint8List _decodeCID(String cid) {
  if (cid.startsWith('Qm')) {
    throw FormatException('CIDv0 is not supported');
  } else if (cid.startsWith('b')) {
    Uint8List base58Decoded = bs58.base58.decode(cid);
    return base58Decoded;
  } else {
    Uint8List decodedData = base32.decode(cid.substring(1));
    return decodedData.sublist(1);
  }
}

void test() {
  String cid = "bafybeibml5uieyxa5tufngvg7fgwbkwvlsuntwbxgtskoqynbt7wlchmfm";
  Uint8List decodedCID = _decodeCID(cid);
  print(decodedCID);
}
