import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/utils/cipher.dart';

final Uint8List key128 = getBytes('128bit-securekey');
final Uint8List key192 = getBytes('192bit-securekeymorebits');

void main() {
  group('Cipher', () {
    test('encrypt with 3-byte password', () {
      var crypto = AESCipher(getBytes('***'));
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[104,5,150,120,128,155,63,168,219,101,47,171,235,120,161,239]'));
    });

    test('encrypt with 16-byte password', () {
      var crypto = AESCipher(key128);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[23,82,75,20,213,2,31,154,151,183,191,37,184,24,155,148]'));
    });

    test('encrypt with 24-byte password', () {
      var crypto = AESCipher(key192);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[192,113,128,236,177,195,161,66,58,114,188,9,16,216,193,185]'));
    });

    test('is two-way', () {
      var crypto = AESCipher(key128);
      var message = getBytes('message');
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(encrypted == decrypted, false);
      expect(decrypted, message);
    });

    test('works with long messages', () {
      var crypto = AESCipher(key192);
      var message = getBytes('A really long message. ' * 1024);
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(decrypted, message);
      expect(decrypted.length, 23552);
    });
  });
}
