import 'package:hive/hive.dart';
import 'package:raven/account.dart';
import 'package:raven/reactives.dart';
import 'boxes.dart' as boxes;
import 'accounts.dart';

// for (var i = 0; i < accountsBox.length; i++) {
//   key: accountsBox.keyAt(i) }
/// run on app init
void toAccounts() {
  boxes.Truth.instance.accounts.watch().listen((BoxEvent event) {
    //event.key is an int, not a accountId...
    if (event.deleted) {
      // remove from accounts if it exists
      Accounts.instance.accounts.remove(event.value.accountId);
      // remove from database if it exists
      boxes.Truth.instance.removeScripthashesOf(event.value.accountId);
      boxes.Truth.instance.accountUnspents.delete(event.value.accountId);
    } else {
      Accounts.instance.accounts[event.key]!.deriveBatch(NodeExposure.Internal);
      Accounts.instance.accounts[event.key]!.deriveBatch(NodeExposure.External);
    }
  });
}

/// run on app init
void toNodes() {
  var internal = boxes.Truth.instance.scripthashAccountIdInternal;
  var external = boxes.Truth.instance.scripthashAccountIdExternal;
  internal.watch().listen((BoxEvent event) {
    // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
    requestBalances(event.key);
    requestUnspents(event.key);
    requestHistories(event.key, event.value);
  });
  external.watch().listen((BoxEvent event) {
    // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
    requestBalances(event.value);
    requestUnspents(event.value);
    requestHistories(event.value, event.value, exposure: NodeExposure.External);
  });
}

/// run on app init
void toUnspents() {
  var unspentsBox = boxes.Truth.instance.unspents;
  var internal = boxes.Truth.instance.scripthashAccountIdInternal;
  var external = boxes.Truth.instance.scripthashAccountIdExternal;
  unspentsBox.watch().listen((BoxEvent event) {
    var accountId = internal.get(event.key) ?? external.get(event.key) ?? '';
    if (accountId != '') {
      sortUnspents(accountId, event.value);
    }
  });
}
