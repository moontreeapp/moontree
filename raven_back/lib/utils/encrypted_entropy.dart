import 'dart:convert';
import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet, KPWallet;

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/utils/cipher.dart';
import 'package:raven/utils/hex.dart' as hex;

class EncryptedEntropy {
  String encryptedEntropy;
  Cipher cipher;

  EncryptedEntropy(this.encryptedEntropy, this.cipher);

  EncryptedEntropy.fromEntropy(entropy, this.cipher)
      : encryptedEntropy = encryptEntropy(entropy, cipher);

  String get secret => mnemonic;

  Uint8List get seed => bip39.mnemonicToSeed(mnemonic);

  String get mnemonic => bip39.entropyToMnemonic(entropy);

  String get entropy =>
      hex.encode(cipher.decrypt(hex.decode(encryptedEntropy)));

  ///String get wif => ///;

  /// this requires that we either do not allow testnet for users or
  /// on import of wallet move from account if wallet exists and
  /// is in an account associated with a different network (testnet vs mainnet)
  String get walletId => HDWallet.fromSeed(seed).pubKey;

  //String encryptEntropy(String givenEntropy, {Cipher? givenCipher}) =>
  //    hex.encode((givenCipher ?? cipher).encrypt(hex.decode(givenEntropy)));

  static String encryptEntropy(String givenEntropy, Cipher givenCipher) =>
      hex.encode(givenCipher.encrypt(hex.decode(givenEntropy)));
}

class EncryptedWIF {
  String encryptedWIF;
  Cipher cipher;

  EncryptedWIF(this.encryptedWIF, this.cipher);

  EncryptedWIF.fromWIF(wif, this.cipher)
      : encryptedWIF = encryptWIF(wif, cipher);

  String get secret => wif;

  String get wif => utf8
      .decode(cipher.decrypt(Uint8List.fromList(utf8.encode(encryptedWIF))));

  String get walletId => KPWallet.fromWIF(wif).pubKey!;

  static String encryptWIF(String givenWif, Cipher givenCipher) => utf8
      .decode(givenCipher.encrypt(Uint8List.fromList(utf8.encode(givenWif))));
}
