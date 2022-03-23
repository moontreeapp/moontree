import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven_back/security/cipher_aes.dart';
import 'package:raven_back/utils/hex.dart' as hex;
import 'package:raven_back/extensions/string.dart';

var cipher = CipherAES('password'.bytesUint8);

void main() {
  group('Hex Utils', () {
    test('encode', () {
      var data = Uint8List.fromList([0, 5, 16, 31, 255]);
      expect(hex.encode(data), '0005101fff');
    });

    test('decode', () {
      var encoded = '0005101fff';
      expect(hex.decode(encoded), Uint8List.fromList([0, 5, 16, 31, 255]));
    });

    test('encrypt', () {
      var data = '0005101fff';
      expect(hex.encrypt(data, cipher), '7cc5c31585e02d3fc2da698ec0ac7ebc');
    });

    test('decrypt', () {
      var data = '7cc5c31585e02d3fc2da698ec0ac7ebc';
      expect(hex.decrypt(data, cipher), '0005101fff');
    });
  });

  group('Hex extras', () {
    test('toHexString', () {
      expect(hex.toHexString('7cc5c31585e0'), '376363356333313538356530');
    });

    test('hexToAscii', () {
      expect(hex.hexToAscii('376363356333313538356530'), '7cc5c31585e0');
    });
  });
}
