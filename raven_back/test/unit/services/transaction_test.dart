// dart test .\test\unit\services\transaction_test.dart
import 'package:ravencoin/ravencoin.dart';
import 'package:test/test.dart';

import 'package:raven_back/services/balance.dart' as balanceService;
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/services/transaction/fee.dart';
import 'package:raven_back/globals.dart';
import '../../fixtures/fixtures.dart' as fixtures;

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() async {
  var wallet = fixtures.wallets().map['0'];

  setUp(fixtures.useFixtureSources);

  group('TransactionBuilder', () {
    test('default transaction version is 1', () {
      var txb = TransactionBuilder(network: mainnet);
      expect(txb.tx!.version, 1);
    });

    test('fee can be calculated', () {
      var txb = TransactionBuilder(network: mainnet);
      expect(txb.tx!.virtualSize(), 10);
      expect(txb.tx!.fee(), 11000);
    });
  });

  group('CollectUTXOs', () {
    setUp(fixtures.useFixtureSources);

    test('fixture utxo set matches exptected', () {
      var utxos = balanceService.BalanceService()
          .sortedUnspents(accounts.primaryIndex.getByKeyStr('a0')[0]);
      expect(utxos.map((utxo) => utxo.value).toList(), [10000000, 5000000]);
    });

    test('pick smallest UTXO of sufficient size', () {
      var utxos = balanceService.BalanceService().collectUTXOs(
          accounts.primaryIndex.getByKeyStr('a0')[0],
          amount: 500);
      expect(utxos.map((utxo) => utxo.value).toList(), [5000000]);
    });
    test('take multiple from the top', () {
      var utxos = balanceService.BalanceService().collectUTXOs(
          accounts.primaryIndex.getByKeyStr('a0')[0],
          amount: 12000000);
      expect(utxos.map((utxo) => utxo.value).toList(), [10000000, 5000000]);
    });
  });
  group('TransactionService', () {
    setUp(fixtures.useFixtureSources);

    test('test BuildTransaction', () {
      var t = TransactionService().buildTransaction(
        accounts.primaryIndex.getByKeyStr('a0')[0],
        //'RM2fJN6HCLKp2DnmKMA5SBYvdKBCvmyaju',
        'mtraysi8CBwHSSmyoEHPKBWZxc4vh6Phpn',
        SendEstimate(4),
      );
      var tx = t.item1;
      var estimate = t.item2;
      expect(tx.fee(), 247500);
      expect(tx.fee(), estimate.fees);
      expect(tx.ins.length, 1);
      expect(tx.outs.length, 2);
      expect(tx.outs[0].value, 4);
      expect(tx.outs[1].value, 4752496);
      expect(tx.outs[1].value! + tx.outs[0].value! + tx.fee(), 5000000);
    });
  });

  // test('choose enough inputs for fee', () async {
  //   var txhelper = tx.TransactionBuilderHelper(
  //       wallet, 3000000, 'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', addresses);
  //   var txb = txhelper.buildTransaction();
  //   expect(txb.tx!.ins.length, 1); // 4000000
  //   expect(txb.tx!.ins[0].hash.toString(),
  //       '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000
  // });
  // ignore: omit_local_variable_types
  // tests.Generated gen = tests.Generated.asEmpty();
  // setUpAll(() async => gen = await tests.generate());
  // tearDownAll(() async => await tests.closeHive());

  /// make amount nearly an entire utxo check to see if by addInputs
  /// we include more utxos to cover the fees
  /*
  test('choose enough inputs for fee', () async {
    var txhelper = tx.TransactionBuilderHelper(
        gen.wallet,
        3000000,
        'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
        gen.reservoirs['addresses'] as AddressReservoir);
    var txb = txhelper.buildTransaction();
    expect(txb.tx!.ins.length, 1); // 4000000
    expect(txb.tx!.ins[0].hash.toString(),
        '[213, 7, 25, 181, 71, 217, 95, 154, 120, 226, 1, 32, 155, 129, 148, 31, 102, 123, 212, 99, 30, 156, 180, 35, 106, 126, 39, 72, 40, 162, 173, 45]'); // 4000000

    txhelper = tx.TransactionBuilderHelper(
        gen.wallet,
        4000000,
        'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
        gen.reservoirs['addresses'] as AddressReservoir);
    txb = txhelper.buildTransaction();
    expect(txb.tx!.ins.length, 1); // 5000087912000
    expect(txb.tx!.ins[0].hash.toString(),
        '[51, 85, 53, 152, 207, 94, 30, 109, 218, 73, 55, 201, 252, 1, 194, 196, 52, 101, 78, 148, 179, 93, 2, 129, 252, 50, 93, 74, 176, 77, 171, 132]'); // 5000087912000

    txhelper = tx.TransactionBuilderHelper(
        gen.wallet,
        5000087912000,
        'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
        gen.reservoirs['addresses'] as AddressReservoir);
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
  */
}
