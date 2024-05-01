import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet_utils/wallet_utils.dart' show HDWallet;

String makeEntropy({String? mnemonic}) =>
    bip39.mnemonicToEntropy(mnemonic ?? makeMnemonic());

String makeMnemonic({String? entropy}) => entropy == null
    ? bip39.generateMnemonic()
    : bip39.entropyToMnemonic(entropy);

Uint8List makeSeed([String? mnemonic]) =>
    bip39.mnemonicToSeed(mnemonic ?? makeMnemonic());

String makePubKey({Uint8List? seed, String? mnemonic}) =>
    HDWallet.fromSeed(seed ?? makeSeed(mnemonic)).pubKey;
