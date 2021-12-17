import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_back/records/records.dart';

Map<String, Wallet> get wallets {
  dotenv.load();
  var phrase = dotenv.env['TEST_WALLET_01']!;
  return {
    'wallet 0': LeaderWallet(
        walletId: 'wallet 0',
        accountId: 'account 0',
        cipherUpdate: CipherUpdate(CipherType.None),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    // has no addresses
    'wallet 1': LeaderWallet(
        walletId: 'wallet 1',
        accountId: 'account 1',
        cipherUpdate: CipherUpdate(CipherType.None),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    'wallet 2': LeaderWallet(
        walletId: 'wallet 2',
        accountId: 'account 2',
        cipherUpdate: CipherUpdate(CipherType.None),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
  };
}
