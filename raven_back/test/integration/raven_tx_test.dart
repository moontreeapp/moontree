// dart --no-sound-null-safety test test/integration/raven_tx_test.dart

import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/transaction.dart' as tx;
import '../test_artifacts.dart' as tests;

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() {
  test('getHistory', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account(ravencoinTestnet, seed: seed);
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.8');
    var scriptHash =
        account.node(4, exposure: NodeExposure.Internal).scriptHash;
    var history = await client.getHistory(scriptHash: scriptHash);
    expect(history, [
      ScriptHashHistory(
          txHash:
              '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
          height: 747308),
      ScriptHashHistory(
          txHash:
              '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
          height: 769767)
    ]); // could fail if people send to this address...
  });

  /// make amount nearly an entire utxo check to see if by addInputs
  /// we include more utxos to cover the fees
  test('choose enough inputs for fee', () async {
    var gen = await tests.generate();

    var txhelper = tx.TransactionBuilderHelper(
        gen.account, 3000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    var txb = txhelper.buildTransaction();
    expect(txb.tx.ins.length, 1); // 4000000
    expect(txb.tx.ins[0].hash.toString(),
        '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000

    txhelper = tx.TransactionBuilderHelper(
        gen.account, 4000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    txb = txhelper.buildTransaction();
    expect(txb.tx.ins.length, 1); // 5000087912000
    expect(txb.tx.ins[0].hash.toString(),
        '[51, 85, 53, 152, 207, 94, 30, 109, 218, 73, 55, 201, 252, 1, 194, 196, 52, 101, 78, 148, 179, 93, 2, 129, 252, 50, 93, 74, 176, 77, 171, 132]'); // 5000087912000

    txhelper = tx.TransactionBuilderHelper(
        gen.account, 5000087912000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    txb = txhelper.buildTransaction();
    expect(txb.tx.ins.length, 2); // 5000087912000 and 4000000
    expect(txb.tx.ins[0].hash.toString(),
        '[51, 85, 53, 152, 207, 94, 30, 109, 218, 73, 55, 201, 252, 1, 194, 196, 52, 101, 78, 148, 179, 93, 2, 129, 252, 50, 93, 74, 176, 77, 171, 132]'); // 5000087912000
    expect(txb.tx.ins[1].hash.toString(),
        '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000

    // TODO figure out how to turn the UInt8List hashes to regular strings
    //expect(String.fromCharCodes(txb.tx.ins[0].hash),
    //    '3U5Ï^\x1EmÚI7Éü\x01ÂÄ4eN³]\x02ü2]J°M«'); // 5000087912000
    //print(utf8.decode(Uint8List.fromList(utf8.encode(txb.tx.ins[0].hash))));
    //print(String.fromCharCodes(txb.tx.ins[0].hash));
    //print(Uint8List.fromList(String.fromCharCodes(txb.tx.ins[0].hash).codeUnits));
  });
}
