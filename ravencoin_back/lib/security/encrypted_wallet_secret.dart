import 'cipher_base.dart';

enum SecretType {
  wif, // SingleWallet
  entropy, // LeaderWallet
  encryptedWif, // LeaderWallet
  encryptedEntropy, // LeaderWallet
  mnemonic,
  none,
  //privateKey,
  //seed,
  //passphrase,
  //password,
  //key,
  //other,
  //unknown,
}

abstract class EncryptedWalletSecret {
  String encryptedSecret;
  CipherBase cipher;

  EncryptedWalletSecret(this.encryptedSecret, this.cipher);

  String get secret;
  String get walletId;
}
