// dart --no-sound-null-safety test test/raven_tx_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/electrum_client.dart';
import 'package:raven/transaction.dart' as tx;
import 'package:raven/env.dart' as env;

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

Future<List> generate() async {
  var phrase = await env.getMnemonic();
  var account = Account(ravencoinTestnet, seed: bip39.mnemonicToSeed(phrase));
  var client = ElectrumClient();
  await client.connect(host: 'testnet.rvn.rocks', port: 50002);
  print('deriving Nodes');
  await account.deriveNodes(client);
  return [phrase, account, client];
}

void main() {
  test('getHistory', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account(ravencoinTestnet, seed: seed);
    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks');
    var scriptHash =
        account.node(4, exposure: NodeExposure.Internal).scriptHash;
    var history = await client.getHistory(scriptHash: scriptHash);
    print(history);
    expect(history, [
      {
        'tx_hash':
            '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
        'height': 747308
      },
      {
        'tx_hash':
            '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
        'height': 769767
      }
    ]); // could fail if people send to this address...
  });

  test('choose enough inputs for fee', () async {
    /* notice this does not calculate an efficient fee or use a utxo set */
    var gen = await generate();
    var account = gen[1];
    var txhelper = tx.TransactionBuilderHelper(
        account, 4000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    var txb = txhelper.buildTransaction();
    // make amount nearly an entire utxo check to see if by addInputs we include more utxos to cover the fees
  });
}
