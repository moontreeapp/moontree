import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/security/security.dart';

final Uint8List key128 = getBytes('128bit-securekey');
final Uint8List key192 = getBytes('192bit-securekeymorebits');

void main() {
  group('Cipher', () {
    test('encrypt with 3-byte password', () {
      var crypto = CipherAES(getBytes('***'));
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[151,29,164,109,35,142,34,11,167,80,44,124,16,217,151,119]'));
    });

    test('encrypt with 16-byte password', () {
      var crypto = CipherAES(key128);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[209,47,94,49,135,107,54,33,165,96,232,58,74,253,138,94]'));
    });

    test('encrypt with 24-byte password', () {
      var crypto = CipherAES(key192);
      expect(
          crypto.encrypt(getBytes('message')),
          jsonDecode(
              '[39,107,118,223,235,15,124,40,10,1,6,87,214,237,214,175]'));
    });

    test('is two-way', () {
      var crypto = CipherAES(key128);
      var message = getBytes('message');
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(encrypted == decrypted, false);
      expect(decrypted, message);
    });

    test('works with long messages', () {
      var crypto = CipherAES(key192);
      var message = getBytes('A really long message. ' * 1024);
      var encrypted = crypto.encrypt(message);
      var decrypted = crypto.decrypt(encrypted);
      expect(decrypted, message);
      expect(decrypted.length, 23552);
    });
  });
}
