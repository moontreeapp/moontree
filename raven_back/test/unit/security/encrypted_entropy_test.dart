import 'package:test/test.dart';

import 'package:raven_back/security/cipher_aes.dart';
import 'package:raven_back/security/encrypted_entropy.dart';
import 'package:raven_back/utils/getBytes.dart';
import '../../fixtures/mnemonic.dart';

var cipher = CipherAES(getBytes('password'));

void main() {
  group('Encrypted Wallet Entropy', () {
    test('recovers mnemonic', () async {
      var encEnt = EncryptedEntropy.fromEntropy(entropy, cipher);
      expect(encEnt.secret, mnemonic);
    });

    test('has walletId', () async {
      var encEnt = EncryptedEntropy.fromEntropy(entropy, cipher);
      expect(encEnt.walletId,
          '02a702fa47681de96f6d48aec00d10503f9efb1ee9eeb5eaf2ac1776c7fee7223a');
    });
  });
}
