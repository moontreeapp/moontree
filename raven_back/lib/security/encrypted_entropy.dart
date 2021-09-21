import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet;

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/utils/hex.dart' as hex;

import 'encrypted_wallet_secret.dart';

class EncryptedEntropy extends EncryptedWalletSecret {
  EncryptedEntropy(encryptedEntropy, cipher) : super(encryptedEntropy, cipher);

  factory EncryptedEntropy.fromEntropy(entropy, cipher) =>
      EncryptedEntropy(hex.encrypt(entropy, cipher), cipher);

  @override
  String get secret => mnemonic;

  /// this requires that we either do not allow testnet for users or
  /// on import of wallet move from account if wallet exists and
  /// is in an account associated with a different network (testnet vs mainnet)
  @override
  String get walletId => HDWallet.fromSeed(seed).pubKey;

  Uint8List get seed => bip39.mnemonicToSeed(mnemonic);

  String get mnemonic => bip39.entropyToMnemonic(entropy);

  String get entropy => hex.decrypt(encryptedSecret, cipher);

  String get encryptedEntropy => hex.encrypt(entropy, cipher);
}
