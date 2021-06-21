// dart --no-sound-null-safety test test/account_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/env.dart' as env;
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';

Future<List> generate() async {
  var phrase = await env.getMnemonic();
  var account = Account(ravencoinTestnet, seed: bip39.mnemonicToSeed(phrase));
  var client = ElectrumClient();
  await client.connect(host: 'testnet.rvn.rocks', port: 50002);
  print('deriving Nodes');
  await account.deriveNodes(client);
  return [phrase, account, client];
}

void main() async {
//  test('deriveNodes then getBalance', () async {
//    var phrase = await env.getMnemonic();
//    var seed = bip39.mnemonicToSeed(phrase);
//    var account = Account(ravencoinTestnet, seed: seed);
//    var client = ElectrumClient();
//    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
//    print('deriving Nodes');
//    var success = await account.deriveNodes(client);
//    expect(success, true);
//    expect((account.getInternals().isEmpty), false);
//    print('getting Balance');
//    var balance = account.getBalance();
//    if (phrase.startsWith('smile')) {
//      expect(balance, 0.0);
//    } else {
//      expect((balance > 0), true);
//    }
//  });

  var gen = await generate();
  test('collectUTXOs small', () async {
    var account = gen[1];
    print('collecting UTXOs');
    var utxos = account.collectUTXOs(100);
    expect(utxos.length, 1);
    expect(utxos[0]['value'], 4000000);
  });

  test('collectUTXOs medium', () async {
    var account = gen[1];
    print('collecting UTXOs');
    var utxos = account.collectUTXOs(5000087912000 - 1);
    expect(utxos.length, 1);
    expect(utxos[0]['value'], 5000087912000);
  });

  test('collectUTXOs big', () async {
    var account = gen[1];
    print('collecting UTXOs');
    var utxos = account.collectUTXOs(5000087912000 + 1);
    expect(utxos.length, 2);
    expect(utxos[0]['value'] + utxos[1]['value'], 5000087912000 + 4000000);
  });
  test('collectUTXOs jumbo', () async {
    var account = gen[1];
    print('collecting UTXOs');
    var utxos = account.collectUTXOs(5000087912000 * 2);
    expect(utxos, []);
  });
}
