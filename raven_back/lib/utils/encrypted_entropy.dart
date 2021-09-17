import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet;

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/utils/cipher.dart';
import 'package:raven/utils/hex.dart' as hex;

class EncryptedEntropy {
  String encryptedEntropy;
  Cipher cipher;

  EncryptedEntropy(this.encryptedEntropy, this.cipher);

  Uint8List get seed => bip39.mnemonicToSeed(mnemonic);

  String get mnemonic => bip39.entropyToMnemonic(entropy);

  String get entropy =>
      hex.encode(cipher.decrypt(hex.decode(encryptedEntropy)));

  ///String get wif => ///;

  /// this requires that we either do not allow testnet for users or
  /// on import of wallet move from account if wallet exists and
  /// is in an account associated with a different network (testnet vs mainnet)
  String get walletId => HDWallet.fromSeed(seed).pubKey;
}
