import 'dart:convert';
import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show KPWallet;

import 'package:raven/security/cipher.dart';

import 'encrypted_wallet_secret.dart';

class EncryptedWIF extends EncryptedWalletSecret {
  EncryptedWIF(encryptedWIF, cipher) : super(encryptedWIF, cipher);

  factory EncryptedWIF.fromWIF(wif, cipher) =>
      EncryptedWIF(encryptWIF(wif, cipher), cipher);

  @override
  String get secret => wif;

  @override
  String get walletId => KPWallet.fromWIF(wif).pubKey!;

  String get wif => utf8
      .decode(cipher.decrypt(Uint8List.fromList(utf8.encode(encryptedSecret))));

  static String encryptWIF(String wif, Cipher cipher) =>
      utf8.decode(cipher.encrypt(Uint8List.fromList(utf8.encode(wif))));
}
