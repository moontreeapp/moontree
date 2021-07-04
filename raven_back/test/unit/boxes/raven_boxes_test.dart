// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:test/test.dart';
import 'package:raven/boxes.dart' as memory;

void main() {
  var truth = memory.Truth.instance;

  test('init', () async {
    truth.init();
  });

  test('load', () async {
    await truth.load();
    expect(truth.boxes['settings']!.length, 1);
    //print(truth.boxes['accounts']!.getAt(0));
    //print(truth.boxes['balances']!.getAt(0));
    await truth.close();
  });

  test('get', () async {
    var accounts = await truth.getAccounts();
    for (var account in accounts) {
      print(account.uid);
      print(await truth.getAccountBalance(account));
    }
  });

  /*
  test('clear', () async {
    await truth.clear();
    expect(truth.boxes['settings']!.length, 0);
    await truth.load();
    expect(truth.boxes['settings']!.length, 1);
    expect(
        truth.boxes['settings']!.get('Electrum Server'), 'testnet.rvn.rocks');
    await truth.boxes['settings']!.put('Electrum Server', 'testnet2.rvn.rocks');
    expect(
        truth.boxes['settings']!.get('Electrum Server'), 'testnet2.rvn.rocks');
  });
*/
}
