import 'package:bip39/bip39.dart' as bip39;
// ignore: implementation_imports
import 'package:bip39/src/wordlists/english.dart' as bip39_wordlists;
import 'package:magic/domain/wallet/wallets.dart';

bool validateMnemonic(String mnemonic) {
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

bool validatePrivateKey(String privkey) {
  try {
    KeypairWallet.privateKeyToWif(privkey);
    return true;
  } catch (_) {
    return false;
  }
}
