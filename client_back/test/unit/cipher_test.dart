import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:client_back/security/security.dart';
import 'package:moontree_utils/moontree_utils.dart';

final Uint8List key128 = '128bit-securekey'.bytesUint8;
final Uint8List key192 = '192bit-securekeymorebits'.bytesUint8;

void main() {
  group('Cipher', () {
    test('encrypt with 3-byte password', () {
      final CipherAES crypto = CipherAES('***'.bytesUint8);
      expect(
          crypto.encrypt('message'.bytesUint8),
          jsonDecode(
              '[151,29,164,109,35,142,34,11,167,80,44,124,16,217,151,119]'));
    });

    test('encrypt with 16-byte password', () {
      final CipherAES crypto = CipherAES(key128);
      expect(
          crypto.encrypt('message'.bytesUint8),
          jsonDecode(
              '[209,47,94,49,135,107,54,33,165,96,232,58,74,253,138,94]'));
    });

    test('encrypt with 24-byte password', () {
      final CipherAES crypto = CipherAES(key192);
      expect(
          crypto.encrypt('message'.bytesUint8),
          jsonDecode(
              '[39,107,118,223,235,15,124,40,10,1,6,87,214,237,214,175]'));
    });

    test('is two-way', () {
      final CipherAES crypto = CipherAES(key128);
      final Uint8List message = 'message'.bytesUint8;
      final Uint8List encrypted = crypto.encrypt(message);
      final Uint8List decrypted = crypto.decrypt(encrypted);
      expect(encrypted == decrypted, false);
      expect(decrypted, message);
    });

    test('works with long messages', () {
      final CipherAES crypto = CipherAES(key192);
      final Uint8List message = ('A really long message. ' * 1024).bytesUint8;
      final Uint8List encrypted = crypto.encrypt(message);
      final Uint8List decrypted = crypto.decrypt(encrypted);
      expect(decrypted, message);
      expect(decrypted.length, 23552);
    });
  });
}
