// dart --no-sound-null-safety test test/integration/account_test.dart --concurrency=1
import 'package:test/test.dart';
import 'package:raven/account.dart';
import '../test_artifacts.dart' as tests;
import 'package:raven/boxes.dart' as boxes;

void main() async {
  var gen;
  setUpAll(() async => gen = await tests.generate());
  tearDownAll(() async => await gen.truth.close());

  test('getBalance', () async {
    expect((gen.account.accountInternals.isEmpty), false);
    var l = await boxes.Truth.instance.balances
        .watch()
        .skipWhile((element) =>
            element.key !=
            '0d78acdf5fe186432cbc073921f83bb146d72c4a81c6bde21c3003f48c15eb38')
        .take(1)
        .toList();
    print(l);
    var balance = gen.account.getBalance();
    print('has balance $balance');
    expect((balance > 0), true);
  });
/*
  test('collectUTXOs for amount smaller than smallest UTXO', () {
    var utxos = gen.account.collectUTXOs(100);
    expect(utxos.length, 1);
    expect(utxos[0].value, 4000000);
  });

  test('collectUTXOs for amount just smaller than largest UTXO', () {
    var utxos = gen.account.collectUTXOs(5000087912000 - 1);
    expect(utxos.length, 1);
    expect(utxos[0].value, 5000087912000);
  });

  test('collectUTXOs for amount larger than largest UTXO', () {
    var utxos = gen.account.collectUTXOs(5000087912000 + 1);
    expect(utxos.length, 2);
    expect(utxos[0].value + utxos[1].value, 5000087912000 + 4000000);
  });

  test('collectUTXOs for amount more than we have', () {
    try {
      var utxos = gen.account.collectUTXOs(5000087912000 * 2);
      expect(utxos, []);
    } on InsufficientFunds catch (e) {
      //print(e);
    }
  });
  */
}
