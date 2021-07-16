// dart --no-sound-null-safety test test/unit/raven_tx_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin/ravencoin.dart';
import 'package:raven/account.dart';
import 'package:raven/models/node_exposure.dart';

void main() {
  test('create, sign, /* and broadcast */ a 1-to-1 transaction', () async {
    /* notice this does not calculate an efficient fee or use a utxo set */
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account.bySeed(ravencoin, seed);
    var node = account.node(4, exposure: NodeExposure.Internal);
    final txb = TransactionBuilder(network: node.network);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
        1); // previous transaction output, has 5000000 satoshis
    // print(txb.tx.virtualSize());
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
        4000000); // (in)5000000 - (out)4000000 = (fee)1000000, this is the miner fee
    // print(txb.tx.virtualSize());
    txb.sign(vin: 0, keyPair: node.keyPair);
    var transaction = txb.build().toHex();
    expect(
        transaction,
        '0100000001ae463c8cf936b87c6800f2b3982c451eb3a15f560789dca3337106'
        'b847c7fc56010000006b4830450221008e6950c7f410e2fe2c0dc3c233a5e210'
        '7dd3a0bf0879c1467c834cdcbcd526b002203bb0a6b54e3715f44f2a25c4eea7'
        '5c904fe721aa4ffbc816cc8836c51c8e9dba01210216c4cab85b35c9e6fa4a0d'
        '88f027e0dbb926db885d3af0325e1ca36c91c0a3d1ffffffff0100093d000000'
        '00001976a9145dbe75f408e8154364e2457a3ab413128e090e3588ac00000000');
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
}
