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

  test('create, sign, /* and broadcast */ a 1-to-1 transaction', () async {
    /* notice this does not calculate an efficient fee or use a utxo set */
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account(ravencoinTestnet, seed: seed);
    var node = account.node(4, exposure: NodeExposure.Internal);
    final txb = TransactionBuilder(network: node.params.network);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
        1); // previous transaction output, has 5000000 satoshis
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
        4000000); // (in)5000000 - (out)4000000 = (fee)1000000, this is the miner fee
    txb.sign(vin: 0, keyPair: node.keyPair);
    var transaction = txb.build().toHex();
    expect(transaction,
        '0100000001ae463c8cf936b87c6800f2b3982c451eb3a15f560789dca3337106b847c7fc56010000006b4830450221008e6950c7f410e2fe2c0dc3c233a5e2107dd3a0bf0879c1467c834cdcbcd526b002203bb0a6b54e3715f44f2a25c4eea75c904fe721aa4ffbc816cc8836c51c8e9dba01210216c4cab85b35c9e6fa4a0d88f027e0dbb926db885d3af0325e1ca36c91c0a3d1ffffffff0100093d00000000001976a9145dbe75f408e8154364e2457a3ab413128e090e3588ac00000000');
    /* broadcast - uncomment to test manually */
    //var client = ElectrumClient();
    //await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    //var result =
    //    await client.request('blockchain.transaction.broadcast', transaction);
    //print(result);
    /* 
      success! https://rvnt.cryptoscope.io/tx/?txid=2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5
      to test broadcast again you must modify the test above and choose a different address that has rvnt in it.
    */
  });

  test('choose enough inputs for fee', () async {
    /* notice this does not calculate an efficient fee or use a utxo set */
    var gen = await generate();
    var account = gen[1];
    // moved ino the class
    var txb = TransactionBuilder(network: account.params.network);
    var amount = 4000000;
    txb.setVersion(1);
    txb.addOutput(
        'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', amount); // 34 bytes? 34 WU?
    amount = amount + 34; // anticipating a change output after...
    var results = tx.addInputs(txb, account, amount);
    txb =
        tx.addChangeOutput(results.txb, account, results.total - results.fees);
    txb = tx.signEachInput(txb, account, results.vins, results.utxos);
    var hex = txb.build().toHex();
    print(hex);
    //// make amount nearly an entire utxo check to see if by addInputs we include more utxos to cover the fees
    ///
    var txhelper = tx.TransactionBuilderHelper(
        account, 4000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    //gets inputs, calculates fee, returns change, converts tx to hex
    var newhex = txhelper.transactionHex();
    print(newhex);
    expect(hex, newhex);
  });
}
