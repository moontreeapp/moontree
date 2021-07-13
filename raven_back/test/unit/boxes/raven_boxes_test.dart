// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:hive/hive.dart';
import 'package:test/test.dart';
import 'package:raven/boxes.dart' as memory;

void main() async {
  late memory.Truth truth;
  setUpAll(() async {
    truth = memory.Truth.instance;
    await truth.open();
  });
  tearDownAll(() async => await truth.close());

  test('loaded', () async {
    //print(truth.settings.getAt(0));
    expect(truth.settings.length > 0, true);
    //expect(truth.accounts.length > 0, true);
    //expect(truth.balances.length > 0, true);
    //print(truth.accounts.getAt(0));
    //print(truth.balances.getAt(0));
  });

  test('get', () async {
    // this is how we can populate the accounts and balances upon app open
    var accounts = await truth.getAccounts();
    // for (var account in accounts) {
    //   print(account.accountId);
    //   print(truth.getAccountBalance(account));
    // }
  });

  test('listen', () async {
    var changes = [];
    var settingsBox = truth.settings;
    for (var i = 0; i < settingsBox.length; i++) {
      settingsBox.watch(key: settingsBox.keyAt(i)).listen((BoxEvent event) {
        var text = '${event.key}: ${event.value}, ${event.deleted}';
        changes.add(text);
        // print(text);
      });
    }
    await settingsBox.put(
        'whatever', await settingsBox.get('whatever', defaultValue: '') + '1');
    await settingsBox.put(
        'Electrum Server', await settingsBox.get('Electrum Server') + '1');
    // for (var item in changes) {
    //   print('changes');
    //   print(item);
    // }
    await settingsBox.close();
    //await Future.delayed(Duration(seconds: 1));
    // print('last');
    // print(changes); // empty
  });
  /*
  test('clear', () async {
    await truth.clear();
    expect(truth.settings.length, 0);
    expect(truth.settings.length, 1);
    expect(
        truth.settings.get('Electrum Server'), 'testnet.rvn.rocks');
    await truth.settings.put('Electrum Server', 'testnet2.rvn.rocks');
    expect(
        truth.settings.get('Electrum Server'), 'testnet2.rvn.rocks');
  });
*/
}
