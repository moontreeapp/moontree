import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'reactives.dart';
import 'records/node_exposure.dart';

import 'buffer_count_window.dart';
import 'models.dart';
import 'subjects/reservoir.dart';
import 'subjects/change.dart';

class AddressSubscriptionService {
  Reservoir accounts;
  Reservoir addresses;
  RavenElectrumClient client;

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(this.accounts, this.addresses, this.client);

  void init() {
    addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((addresses) async {
      var scripthashes =
          addresses.map((address) => address.scripthash).toList();
      // ignore: omit_local_variable_types
      List<ScripthashBalance> balances = await client.getBalances(scripthashes);
      // ignore: omit_local_variable_types
      List<List<ScripthashHistory>> histories =
          await client.getHistories(scripthashes);
      // ignore: omit_local_variable_types
      List<List<ScripthashUnspent>> unspents =
          await client.getUnspents(scripthashes);
      zip([addresses, balances, histories, unspents]).forEach((element) {
        var address = element[0] as Address;
        Account account = accounts.data[address.accountId];
        address.setBalance(element[1] as ScripthashBalance);
        account.addHistory(
            address.scripthash, element[2] as List<ScripthashHistory>);
        account.addUnspents(element[3] as List<ScripthashUnspent>);
      });
    });

    addresses.changes.listen((change) {
      change.when(added: (added) {
        Address address = added.data;
        var stream = client.subscribeScripthash(address.scripthash);
        // => notifies us when a scripthash 'changes' (doesn't tell us the values that changed)
        addressesNeedingUpdate.sink.add(address);
        stream.listen((status) {
          addressesNeedingUpdate.sink.add(address);
        });
      }, updated: (updated) {
        // pass - see initialize.dart
      }, removed: (removed) {
        // pass - see initialize.dart
      });
    });
  }
}
