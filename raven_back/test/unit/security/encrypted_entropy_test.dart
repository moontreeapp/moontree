import 'dart:convert';

import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/security/cipher.dart' show getBytes;
import 'package:raven/security/cipher_aes.dart';
import 'package:raven/security/encrypted_entropy.dart';

var mnemonic = // random mnemonic for tests
    'daring field mesh message '
    'behave tenant immense shrimp '
    'asthma gadget that mammal';
var entropy = bip39.mnemonicToEntropy(mnemonic);
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
