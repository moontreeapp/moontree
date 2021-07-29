import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'buffer_count_window.dart';
import 'models.dart';
import 'subjects/reservoir.dart';

class AddressSubscriptionService {
  Reservoir accounts;
  Reservoir addresses;
  RavenElectrumClient client;

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(this.accounts, this.addresses, this.client);

  void init() {
    addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      var scripthashes =
          changedAddresses.map((address) => address.scripthash).toList();
      // ignore: omit_local_variable_types
      List<ScripthashBalance> balances = await client.getBalances(scripthashes);
      // ignore: omit_local_variable_types
      List<List<ScripthashHistory>> histories =
          await client.getHistories(scripthashes);
      // ignore: omit_local_variable_types
      List<List<ScripthashUnspent>> unspents =
          await client.getUnspents(scripthashes);
      zip([changedAddresses, balances, histories, unspents]).forEach((element) {
        var address = element[0] as Address;
        Account account = accounts.data[address.accountId];
        address.setBalance(element[1] as ScripthashBalance);
        account.addHistory(
            address.scripthash, element[2] as List<ScripthashHistory>);
        account.addUnspents(element[3] as List<ScripthashUnspent>);
      });
      // see if we need to derive more addresses for each account
      for (var address in changedAddresses) {
        Account account = accounts.data[address.accountId];
        var internalHDIndex = addresses.indices['account-exposure']!
            .size('${account.accountId}:${NodeExposure.Internal}');
        var externalHDIndex = addresses.indices['account-exposure']!
            .size('${account.accountId}:${NodeExposure.External}');
        for (var newAddress
            in account.deriveMore(internalHDIndex, NodeExposure.Internal)) {
          addresses.save(newAddress);
        }
        for (var newAddress
            in account.deriveMore(externalHDIndex, NodeExposure.External)) {
          addresses.save(newAddress);
        }
      }
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
