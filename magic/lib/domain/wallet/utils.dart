import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet_utils/wallet_utils.dart' show HDWallet;

String makeMnemonic({String? entropy, int wordCount = 12}) {
  if (wordCount != 12 && wordCount != 24) {
    throw ArgumentError('Word count must be either 12 or 24.');
  }
  if (entropy != null) {
    return bip39.entropyToMnemonic(entropy);
  }
  int entropyBits = wordCount == 12 ? 128 : 256;
  return bip39.generateMnemonic(strength: entropyBits);
}

String makeEntropy({String? mnemonic, int wordCount = 12}) =>
    bip39.mnemonicToEntropy(mnemonic ?? makeMnemonic(wordCount: wordCount));

Uint8List makeSeed([String? mnemonic, int wordCount = 12]) =>
    bip39.mnemonicToSeed(mnemonic ?? makeMnemonic(wordCount: wordCount));

String makePubKey({Uint8List? seed, String? mnemonic, int wordCount = 12}) =>
    HDWallet.fromSeed(seed ?? makeSeed(mnemonic, wordCount)).pubKey;
