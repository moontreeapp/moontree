// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:hive/hive.dart';
import 'package:test/test.dart';
import 'package:raven/boxes.dart' as memory;
import 'package:hive/hive.dart';

void main() async {
  var truth = memory.Truth.instance;
  var friends = await truth.open('friends');
  await friends.clear();

  await friends.add('0Lisa'); // index 0, key 0
  await friends.add('1Dave'); // index 1, key 1
  await friends.put(123, '2Marco'); // index 2, key 123
  await friends.add('3Paul'); // index 3, key 124

  for (var i = 0; i < friends.length; i++) {
    print(i);
    print(friends.getAt(i));
  }

  await friends.deleteAt(1);

  for (var i = 0; i < friends.length; i++) {
    print(i);
    print(friends.getAt(i));
  }

/*
void main() {
  var truth = memory.Truth.instance;

  test('loaded', () async {
    expect(truth.settings.length > 0, true);
    expect(truth.accounts.length > 0, true);
    expect(truth.balances.length > 0, true);
    //print(truth.accounts.getAt(0));
    //print(truth.balances.getAt(0));
  });

  test('get', () async {
    // this is how we can populate the accounts and balances upon app open
    var accounts = await truth.getAccounts();
    for (var account in accounts) {
      print(account.accountId);
      print(await truth.getAccountBalance(account));
    }
  });

  test('listen', () async {
    var changes = [];
    var settingsBox = truth.settings;
    for (var i = 0; i < settingsBox.length; i++) {
      settingsBox.watch(key: settingsBox.keyAt(i)).listen((BoxEvent event) {
        var text = '${event.key}: ${event.value}, ${event.deleted}';
        changes.add(text);
        print(text);
      });
    }
    await settingsBox.put('whatever', await settingsBox.get('whatever') + '1');
    await settingsBox.put(
        'Electrum Server', await settingsBox.get('Electrum Server') + '1');
    for (var item in changes) {
      print('changes');
      print(item);
    }
    await settingsBox.close();
    //await Future.delayed(Duration(seconds: 1));
    print('last');
    print(changes); // empty
  });
  */
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
