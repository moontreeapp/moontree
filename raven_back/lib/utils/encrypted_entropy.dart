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

  String encryptEntropy(String givenEntropy) =>
      hex.encode(cipher.encrypt(hex.decode(givenEntropy)));
}

class EncryptedWIF {
  String encryptedWIF;
  Cipher cipher;

  EncryptedWIF(this.encryptedWIF, this.cipher);

  String get secret => wif;

  String get wif => utf8
      .decode(cipher.decrypt(Uint8List.fromList(utf8.encode(encryptedWIF))));

  String getWalletId() => KPWallet.fromWIF(wif).pubKey!;

  String encryptWIF(String givenWif) =>
      utf8.decode(cipher.encrypt(Uint8List.fromList(utf8.encode(givenWif))));
}
