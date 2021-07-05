// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:test/test.dart';
import 'package:raven/boxes.dart' as memory;

void main() {
  var truth = memory.Truth.instance;

  test('init', () async {
    truth.init();
  });

  test('load', () async {
    await truth.open();
    expect(truth.settings.length, 1);
    expect(truth.accounts.length > 0, true);
    expect(truth.balances.length > 0, true);
    //print(truth.accounts.getAt(0));
    //print(truth.balances.getAt(0));
    await truth.close();
  });

  test('get', () async {
    // this is how we can populate the accounts and balances upon app open
    var accounts = await truth.getAccounts();
    for (var account in accounts) {
      print(account.uid);
      print(await truth.getAccountBalance(account));
    }
  });

  /*
  test('clear', () async {
    await truth.clear();
    expect(truth.settings.length, 0);
    await truth.open();
    expect(truth.settings.length, 1);
    expect(
        truth.settings.get('Electrum Server'), 'testnet.rvn.rocks');
    await truth.settings.put('Electrum Server', 'testnet2.rvn.rocks');
    expect(
        truth.settings.get('Electrum Server'), 'testnet2.rvn.rocks');
  });
*/
}
