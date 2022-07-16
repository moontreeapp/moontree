import 'cipher_base.dart';

enum SecretType {
  wif,
  mnemonic,
  none,
}

abstract class EncryptedWalletSecret {
  String encryptedSecret;
  CipherBase cipher;

  EncryptedWalletSecret(this.encryptedSecret, this.cipher);

  String get secret;
  String get walletId;
}
