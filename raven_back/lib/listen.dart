import 'package:hive/hive.dart';
import 'package:raven/reactives.dart';
import 'boxes.dart' as boxes;

/// run on app init
Future toAccounts() async {
  var accountsBox = await boxes.Truth.instance.open('accounts');
  for (var i = 0; i < accountsBox.length; i++) {
    accountsBox.watch(key: accountsBox.keyAt(i)).listen((BoxEvent event) {
      // where be in-memory account objects?
      //accounts[event.key].driveBatch(
      //  event.value, /* how is exposure determined? */
      //);
    });
  }
}

/// run on app init
Future toNodes() async {
  var nodesBox = await boxes.Truth.instance.open('nodes');
  nodesBox.watch().listen((BoxEvent event) {
    // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
    requestBalance(event.value);
  });
  await nodesBox.close();
}

/// run on app init
Future toUnspents() async {
  var unspentsBox = await boxes.Truth.instance.open('unspents');
  unspentsBox.watch().listen((BoxEvent event) {
    // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
    requestBalance(event.value);
  });
  await unspentsBox.close();
}
