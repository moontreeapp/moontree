import 'package:moontree_utils/types/cipher_base.dart';

enum SecretType {
  wif, // SingleWallet
  entropy, // LeaderWallet
  encryptedWif, // LeaderWallet
  encryptedEntropy, // LeaderWallet
  saltedHashedPassword, // Password
  mnemonic,
  none,
  //privateKey,
  //seed,
  //passphrase,
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
