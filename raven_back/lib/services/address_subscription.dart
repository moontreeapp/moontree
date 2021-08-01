import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven/models/balance.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/services/accounts.dart' show AccountsService;
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../buffer_count_window.dart';
import '../models.dart';
import '../reservoir/reservoir.dart';

class ScripthashRow {
  final Address address;
  final ScripthashBalance balance;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;

  ScripthashRow(this.address, this.balance, this.history, this.unspent);
}

class ScripthashData {
  final List<Address> addresses;
  final List<ScripthashBalance> balances;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;

  ScripthashData(this.addresses, this.balances, this.histories, this.unspents);

  Iterable<ScripthashRow> get zipped =>
      zip([addresses, balances, histories, unspents]).map((e) => ScripthashRow(
          e[0] as Address,
          e[1] as ScripthashBalance,
          e[2] as List<ScripthashHistory>,
          e[3] as List<ScripthashUnspent>));
}

class AddressSubscriptionService {
  Reservoir accounts;
  Reservoir addresses;
  Reservoir histories;
  RavenElectrumClient client;
  AccountsService accountsService;

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(this.accounts, this.addresses, this.histories,
      this.client, this.accountsService);

  void init() {
    addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      saveScripthashData(await getScripthashData(changedAddresses));
      maybeDeriveNewAddresses(changedAddresses);
    });

    addresses.changes.listen((change) {
      change.when(added: (added) {
        Address address = added.data;
        addressNeedsUpdating(address);
        setupAddressSubscription(address);
      }, updated: (updated) {
        // pass - see initialize.dart
      }, removed: (removed) {
        // pass - see initialize.dart
      });
    });
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void setupAddressSubscription(Address address) {
    var stream = client.subscribeScripthash(address.scripthash);
    stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  Future<ScripthashData> getScripthashData(
      List<Address> changedAddresses) async {
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
    return ScripthashData(changedAddresses, balances, histories, unspents);
  }

  void saveScripthashData(ScripthashData data) async {
    data.zipped.forEach((row) {
      var address = row.address;
      address.balance = Balance.fromScripthashBalance(row.balance);
      addresses.save(address);
      histories.saveAll(combineHistoryAndUnspents(row));
    });
  }

  List combineHistoryAndUnspents(ScripthashRow row) {
    var newHistories = [];
    for (var history in row.history) {
      newHistories.add(History.fromScripthashHistory(
          row.address.accountId, row.address.scripthash, history));
    }
    for (var unspent in row.unspent) {
      newHistories.add(History.fromScripthashUnspent(
          row.address.accountId, row.address.scripthash, unspent));
    }
    return newHistories;
  }

  void maybeDeriveNewAddresses(List<Address> changedAddresses) async {
    for (var address in changedAddresses) {
      Account account = accounts.data[address.accountId];
      maybeSaveNewAddress(account, NodeExposure.Internal);
      maybeSaveNewAddress(account, NodeExposure.External);
    }
  }

  void maybeSaveNewAddress(Account account, NodeExposure exposure) {
    var newAddress =
        accountsService.maybeDeriveNextAddress(account.accountId, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }
}
