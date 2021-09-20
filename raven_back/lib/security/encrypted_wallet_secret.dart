import 'cipher.dart';

abstract class EncryptedWalletSecret {
  String encryptedSecret;
  Cipher cipher;

  EncryptedWalletSecret(this.encryptedSecret, this.cipher);

  String get secret;
  String get walletId;
}
