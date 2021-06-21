// dart --no-sound-null-safety test test/account_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/env.dart' as env;
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';

void main() {
  test('getBalance after deriveNodes', () async {
    var phrase = await env.getMnemonic();
    var seed = bip39.mnemonicToSeed(phrase);
    var account = Account(ravencoinTestnet, seed: seed);
    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    var success = await account.deriveNodes(client);
    expect(success, true);
    expect((account.getInternals().isEmpty), false);
    print('getting Balance');
    var balance = await account.getBalance(client);
    if (phrase.startsWith('smile')) {
      expect(balance, 0.0);
    } else {
      expect((balance > 0), true);
    }
  });
}
