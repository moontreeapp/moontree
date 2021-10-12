import 'cipher_base.dart';

abstract class EncryptedWalletSecret {
  String encryptedSecret;
  CipherBase cipher;

  EncryptedWalletSecret(this.encryptedSecret, this.cipher);

  String get secret;
  String get walletId;
}
