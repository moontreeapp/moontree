import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:bs58check/bs58check.dart' as bs58;

import 'package:ravencoin_back/security/cipher_base.dart';
import 'package:ravencoin_back/utilities/hex.dart' as hex;
import 'package:ravencoin_back/proclaim/proclaim.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import 'encrypted_wallet_secret.dart';

class EncryptedWIF extends EncryptedWalletSecret {
  EncryptedWIF(String encryptedWIF, CipherBase cipher)
      : super(encryptedWIF, cipher);

  factory EncryptedWIF.fromWIF(String wif, CipherBase cipher) =>
      EncryptedWIF(encryptWIF(wif, cipher), cipher);

  @override
  String get secret => wif;

  // A public key exposes some data; we may not want to have it as our id.
  // Instead lets hash our raw WIF
  //@override
  //String get walletId => sha256.convert(wif.codeUnits).toString();
  // we're already exposing the publickey as the wallet id on the Leaders so
  // just to remain consistent, we'll do that on Singles too.
  @override
  String get walletId => pubkey;

  String get pubkey => KPWallet.fromWIF(wif, pros.settings.network).pubKey!;

  String get wif => bs58.encode(cipher.decrypt(hex.decode(encryptedSecret)));

  static String encryptWIF(String wif, CipherBase cipher) =>
      hex.encode(cipher.encrypt(Uint8List.fromList(bs58.decode(wif))));

  static SecretType get secretType => SecretType.wif;
}
