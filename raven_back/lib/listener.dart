import 'package:hive/hive.dart';
import 'package:raven/reactives.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

/// setup listeners on init
class BoxListener {
  RavenElectrumClient client;

  BoxListener(this.client);

  void toAccounts() {
    Hive.box('accounts').watch().listen((BoxEvent event) {
      //event.key is an int, not a accountId... ?
      if (event.deleted) {
        // if we delete an account we need to get rid of everything:
        // someone deletes the wallet -> we delete the Account -> ??
        //   - remove Account record from a Account box
        //     - unsubscribe from addresses (scripthash)
        //     - delete in-memory addresses
        //     - delete in-memory balances, histories, unspents
        //     - UI updates
        // remove from database if it exists
        //Truth.instance.removeScripthashesOf(event.value.accountId);
        //Truth.instance.accountUnspents.delete(event.value.accountId);
      } else {
        // is event.value an Account or an Account Model or record?
        // anyway convert to account and derive stuff
        event.value.deriveBatch(NodeExposure.Internal);
        event.value.deriveBatch(NodeExposure.External);
      }
    });
  }

  void toNodesBatch() {
    Hive.box('scripthashAccountIdInternal').watch().listen((BoxEvent event) {
      // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
      requestBalances(event.key, client);
      requestUnspents(event.key, client);
      requestHistories(event.key, event.value, client);
    });
    Hive.box('scripthashAccountIdExternal').watch().listen((BoxEvent event) {
      // event.value is the batch, must buffer content here or use rxdart to buffer... https://pub.dev/packages/rxdart
      requestBalances(event.value, client);
      requestUnspents(event.value, client);
      requestHistories(event.value, event.value, client,
          exposure: NodeExposure.External);
    });
  }

  // delete once batch is working
  void toNodes() {
    Hive.box('scripthashAccountIdInternal')
        .watch()
        .listen((BoxEvent event) async {
      await requestBalance(event.key, client);
      await requestUnspent(event.key, client);
      await requestHistory(event.key, event.value, client);
    });
    Hive.box('scripthashAccountIdExternal')
        .watch()
        .listen((BoxEvent event) async {
      await requestBalance(event.key, client);
      await requestUnspent(event.key, client);
      await requestHistory(event.key, event.value, client,
          exposure: NodeExposure.External);
    });
  }

  void toUnspents() {
    Hive.box('unspents').watch().listen((BoxEvent event) {
      var accountId = Hive.box('scripthashAccountIdInternal').get(event.key) ??
          Hive.box('scripthashAccountIdExternal').get(event.key) ??
          '';
      if (accountId != '') {
        flattenUnspents(accountId, event.value);
      }
    });
  }
}
