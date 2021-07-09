import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/cipher.dart';

final Uint8List key128 = getBytes('128bit-securekey');
final Uint8List key192 = getBytes('192bit-securekeymorebits');

void main() {
  group('Cipher', () {
    test('encrypt with 128bit key', () {
      var crypto = Cipher(key128);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[74,119,11,56,38,77,218,106,50,101,161,80,183,210,35,42]'));
    });

    test('encrypt with 192bit key', () {
      var crypto = Cipher(key192);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[119,135,142,140,144,81,191,124,119,93,48,203,86,39,63,106]'));
    });

    test('is two-way', () {
      var crypto = Cipher(key128);
      var message = getBytes('message');
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(encrypted == decrypted, false);
      expect(decrypted, message);
    });

    test('works with long messages', () {
      var crypto = Cipher(key192);
      var message = getBytes('A really long message. ' * 1024);
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(decrypted, message);
      expect(decrypted.length, 23552);
    });
  });
}
