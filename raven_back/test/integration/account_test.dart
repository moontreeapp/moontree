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
  await account.deriveNodes(client);
  return [phrase, account, client];
}

void main() async {
  var gen = await generate();

  test('getBalance', () async {
    var phrase = gen[0];
    var account = gen[1];
    expect((account.getInternals().isEmpty), false);
    var balance = account.getBalance();
    if (phrase.startsWith('smile')) {
      expect(balance, 0.0);
    } else {
      expect((balance > 0), true);
    }
  });

  test('collectUTXOs for amount smaller than smallest UTXO', () {
    var account = gen[1];
    var utxos = account.collectUTXOs(100);
    expect(utxos.length, 1);
    expect(utxos[0]['value'], 4000000);
  });

  test('collectUTXOs for amount just smaller than largest UTXO', () {
    var account = gen[1];
    var utxos = account.collectUTXOs(5000087912000 - 1);
    expect(utxos.length, 1);
    expect(utxos[0]['value'], 5000087912000);
  });

  test('collectUTXOs for amount larger than largest UTXO', () {
    var account = gen[1];
    var utxos = account.collectUTXOs(5000087912000 + 1);
    expect(utxos.length, 2);
    expect(utxos[0]['value'] + utxos[1]['value'], 5000087912000 + 4000000);
  });

  test('collectUTXOs for amount more than we have', () {
    var account = gen[1];
    try {
      var utxos = account.collectUTXOs(5000087912000 * 2);
      expect(utxos, []);
    } on InsufficientFunds catch (e) {
      print(e);
    }
  });
}
