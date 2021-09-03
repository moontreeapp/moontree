import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Wallet> wallets() {
  dotenv.load();
  var phrase = dotenv.env['TEST_WALLET_01']!;
  return MapSource({
    '0': LeaderWallet(
        id: '0', accountId: 'a0', encryptedSeed: bip39.mnemonicToSeed(phrase)),
  });
}
