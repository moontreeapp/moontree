import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:bip39/bip39.dart' as bip39;
// ignore: implementation_imports
import 'package:bip39/src/wordlists/english.dart' as bip39_wordlists;
import 'package:magic/domain/wallet/wallets.dart';

bool isValidMnemonic(String mnemonic) {
  if (mnemonic.isEmpty) return false;

  // Split mnemonic into words
  List<String> words = mnemonic.split(' ');

  // Validate word count
  if (![12, 15, 18, 21, 24].contains(words.length)) return false;

  // Validate each word
  for (String word in words) {
    if (!bip39_wordlists.WORDLIST.contains(word)) {
      return false;
    }
  }

  // Validate mnemonic using BIP39 library
  return bip39.validateMnemonic(mnemonic);
}

bool isValidWif(String wif) {
  try {
    // Decode WIF key
    Uint8List decodedKey = bs58check.decode(wif);

    // Check the length of the decoded key (should be 33 bytes for compressed, 32 for uncompressed + version byte + checksum)
    if (decodedKey.length != 33 && decodedKey.length != 34) {
      return false;
    }

    // Check if the first byte is the correct version byte for mainnet or testnet
    int versionByte = decodedKey[0];
    if (versionByte != 0x80 && versionByte != 0xEF) {
      return false;
    }

    // Check for compressed key flag (last byte should be 0x01 if compressed)
    if (decodedKey.length == 34 && decodedKey[33] != 0x01) {
      return false;
    }

    // If all checks pass, it's a valid WIF key
    return true;
  } catch (_) {
    // If any error occurs during decoding, it's not a valid WIF key
    return false;
  }
}

bool isValidPrivateKey(String privkey) {
  try {
    KeypairWallet.privateKeyToWif(privkey);
    return true;
  } catch (_) {
    return false;
  }
}
