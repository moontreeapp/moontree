import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show KPWallet;
import 'package:bs58check/bs58check.dart' as bs58;

import 'package:raven/security/cipher_base.dart';
import 'package:raven/utils/hex.dart' as hex;

import 'encrypted_wallet_secret.dart';

class EncryptedWIF extends EncryptedWalletSecret {
  EncryptedWIF(String encryptedWIF, CipherBase cipher)
      : super(encryptedWIF, cipher);

  factory EncryptedWIF.fromWIF(String wif, CipherBase cipher) =>
      EncryptedWIF(encryptWIF(wif, cipher), cipher);

  @override
  String get secret => wif;

  @override
  String get walletId => KPWallet.fromWIF(wif).pubKey!;

  String get wif => bs58.encode(cipher.decrypt(hex.decode(encryptedSecret)));

  static String encryptWIF(String wif, CipherBase cipher) =>
      hex.encode(cipher.encrypt(Uint8List.fromList(bs58.decode(wif))));

  static SecretType get secretType => SecretType.wif;
}
