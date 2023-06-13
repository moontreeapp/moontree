import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

extension BigIntExtensions on BigInt {
  List<int> toRadixList(int radix, {int? width}) {
    final List<int> result = [];

    BigInt value = this;
    final BigInt bigRadix = BigInt.from(radix);
    final BigInt? bigWidth = width != null ? BigInt.from(width) : null;

    while (value > BigInt.zero) {
      BigInt digit = value % bigRadix;
      value ~/= bigRadix;

      if (bigWidth != null) {
        digit = digit.toUnsigned(bigWidth.toInt());
      }

      result.add(digit.toInt());
    }

    return result.reversed.toList();
  }
}

Uint8List base58Decode(String input) {
  const String base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  int base = base58Alphabet.length;

  BigInt result = BigInt.zero;
  int leadingZerosCount = 0;

  for (int i = 0; i < input.length; i++) {
    int charIndex = base58Alphabet.indexOf(input[i]);
    if (charIndex == -1) {
      throw FormatException('Invalid character at index $i');
    }

    result = result * BigInt.from(base) + BigInt.from(charIndex);

    if (input[i] == '1') {
      leadingZerosCount++;
    } else {
      leadingZerosCount = 0;
    }
  }

  Uint8List decodedBytes = Uint8List.fromList(
      result.toUnsigned(leadingZerosCount * 8).toRadixList(256));
  return decodedBytes;
}

Uint8List base32Decode(String input) {
  const String base32Alphabet = 'abcdefghijklmnopqrstuvwxyz234567';

  int bits = 0;
  int bitsRemaining = 0;
  List<int> bytes = [];

  for (int i = 0; i < input.length; i++) {
    int value = base32Alphabet.indexOf(input[i]);
    if (value == -1) {
      throw FormatException('Invalid character at index $i');
    }
    bits |= value;
    bitsRemaining += 5;
    if (bitsRemaining >= 8) {
      bytes.add(bits >> (bitsRemaining - 8));
      bits &= (1 << (bitsRemaining - 8)) - 1;
      bitsRemaining -= 8;
    }
  }

  int paddingBytes = (bitsRemaining ~/ 5) * 8 ~/ 5;
  if (paddingBytes > 0) {
    bytes.add(bits << (8 - bitsRemaining));
    bytes = bytes.sublist(0, bytes.length - paddingBytes);
  }

  return Uint8List.fromList(bytes);
}

Uint8List decodeCID(String cid) {
  if (cid.length == 46 && cid.startsWith('Qm')) {
    return base58Decode(cid);
  }

  String multibasePrefix = cid[0];
  String encodedString = cid.substring(1);

  Uint8List decodedBytes;

  switch (multibasePrefix) {
    case 'b': // Base16
      //  decodedBytes = Uint8List.fromList(hex.decode(encodedString));
      decodedBytes = base32Decode(encodedString.substring(3));
      break;
    case 'f': // Base16 uppercase
      decodedBytes =
          Uint8List.fromList(hex.decode(encodedString.toUpperCase()));
      break;
    case 'z': // Base58 with sha256 multihash
      decodedBytes = base58Decode(encodedString);
      break;
    case 'v': // Base32 with sha256 multihash
      decodedBytes = base32Decode(encodedString);
      break;
    default:
      throw FormatException('Unsupported multibase encoding: $multibasePrefix');
  }

  if (decodedBytes[0] == 0x12) {
    throw FormatException('Invalid CID: CIDv0 may not be multibase encoded');
  }

  return decodedBytes;
}

void main() {
  String cid = "bafybeibml5uieyxa5tufngvg7fgwbkwvlsuntwbxgtskoqynbt7wlchmfm";

  Uint8List decodedCID = decodeCID(cid);

  if (decodedCID.length == 34 && decodedCID[0] == 0x12) {
    // CIDv0
    print("CIDv0");
    // Decode multihash, multicodec, etc.
  } else {
    // CIDv1
    print("CIDv1");
    int version = decodedCID[0];
    if (version == 1) {
      // Decode multihash, multicodec, etc.
    } else if (version <= 0) {
      throw FormatException('Malformed CID');
    } else {
      throw FormatException('CID version $version is reserved');
    }
  }
}
