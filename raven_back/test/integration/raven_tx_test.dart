// dart --no-sound-null-safety test test/integration/raven_tx_test.dart

import 'package:test/test.dart';

import 'package:raven/transaction.dart' as tx;

import '../test_artifacts.dart' as tests;

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() async {
  var gen;
  setUpAll(() async => gen = await tests.generate());
  tearDownAll(() async => await gen.truth.close());

  /// make amount nearly an entire utxo check to see if by addInputs
  /// we include more utxos to cover the fees
  test('choose enough inputs for fee', () async {
    var txhelper = tx.TransactionBuilderHelper(
        gen.account, 3000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    var txb = txhelper.buildTransaction();
    expect(txb.tx!.ins.length, 1); // 4000000
    expect(txb.tx!.ins[0].hash.toString(),
        '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000

    txhelper = tx.TransactionBuilderHelper(
        gen.account, 4000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    txb = txhelper.buildTransaction();
    expect(txb.tx!.ins.length, 1); // 5000087912000
    expect(txb.tx!.ins[0].hash.toString(),
        '[51, 85, 53, 152, 207, 94, 30, 109, 218, 73, 55, 201, 252, 1, 194, 196, 52, 101, 78, 148, 179, 93, 2, 129, 252, 50, 93, 74, 176, 77, 171, 132]'); // 5000087912000

    txhelper = tx.TransactionBuilderHelper(
        gen.account, 5000087912000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7');
    txb = txhelper.buildTransaction();
    expect(txb.tx!.ins.length, 2); // 5000087912000 and 4000000
    expect(txb.tx!.ins[0].hash.toString(),
        '[51, 85, 53, 152, 207, 94, 30, 109, 218, 73, 55, 201, 252, 1, 194, 196, 52, 101, 78, 148, 179, 93, 2, 129, 252, 50, 93, 74, 176, 77, 171, 132]'); // 5000087912000
    expect(txb.tx!.ins[1].hash.toString(),
        '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000

    // TODO figure out how to turn the UInt8List hashes to regular strings
    //expect(String.fromCharCodes(txb.tx.ins[0].hash),
    //    '3U5Ï^\x1EmÚI7Éü\x01ÂÄ4eN³]\x02ü2]J°M«'); // 5000087912000
    //print(utf8.decode(Uint8List.fromList(utf8.encode(txb.tx.ins[0].hash))));
    //print(String.fromCharCodes(txb.tx.ins[0].hash));
    //print(Uint8List.fromList(String.fromCharCodes(txb.tx.ins[0].hash).codeUnits));
  });
}
