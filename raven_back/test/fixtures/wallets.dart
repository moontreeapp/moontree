import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Wallet> wallets() {
  dotenv.load();
  var phrase = dotenv.env['TEST_WALLET_01']!;
  return MapSource({
    '0': LeaderWallet(
        walletId: '0',
        accountId: 'a0',
        cipherUpdate: CipherUpdate(CipherType.None, 0),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    // has no addresses
    '1': LeaderWallet(
        walletId: '1',
        accountId: 'a1',
        cipherUpdate: CipherUpdate(CipherType.None, 0),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    '2': LeaderWallet(
        walletId: '2',
        accountId: 'a2',
        cipherUpdate: CipherUpdate(CipherType.None, 0),
        encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
  });
}
