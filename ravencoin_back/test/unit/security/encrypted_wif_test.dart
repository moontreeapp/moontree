import 'package:test/test.dart';

import 'package:ravencoin_back/security/cipher_aes.dart';
import 'package:ravencoin_back/security/encrypted_wif.dart';
import 'package:ravencoin_back/extensions/string.dart';
import 'package:moontree_utils/moontree_utils.dart';

// WIF derived from 'daring field mesh message behave tenant immense shrimp asthma gadget that mammal'
var wif = 'L3H4yjsqop3NY4kncJ6WLsyrhjiCRrvn3xw4pztQgP5EiCeLZ23c';
var cipher = CipherAES('password'.bytesUint8);

void main() {
  group('Encrypted Wallet Entropy', () {
    test('recovers wif', () async {
      var encEnt = EncryptedWIF.fromWIF(wif, cipher);
      expect(encEnt.secret, wif);
    });

    test('has walletId', () async {
      var encEnt = EncryptedWIF.fromWIF(wif, cipher);
      expect(encEnt.walletId,
          '02a702fa47681de96f6d48aec00d10503f9efb1ee9eeb5eaf2ac1776c7fee7223a');
    });
  });
}
