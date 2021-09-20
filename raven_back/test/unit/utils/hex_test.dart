import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/security/cipher.dart';
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/utils/hex.dart' as hex;

var cipher = CipherAES(getBytes('password'));

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
}
