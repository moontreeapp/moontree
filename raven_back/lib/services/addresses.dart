import 'dart:async';

import 'package:raven/models.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/services/service.dart';

class AddressesService extends Service {
  AccountReservoir accounts;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressesService(this.accounts, this.addresses, this.histories) : super();

  @override
  void init() {
    //AddressSubscriptionService(accounts, addresses, client);
    listener = addresses.changes.listen((change) {
      change.when(added: (added) {
        // pass - see AddressSubscriptionService
      }, updated: (updated) {
        Address address = updated.data;
        accounts.setBalance(
            address.accountId, calculateBalance(address.accountId));
      }, removed: (removed) {
        // always triggered by account removal
        histories.removeHistories(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }

  Balance calculateBalance(String accountId) {
    return addresses.indices['account']!.getAll(accountId).fold(
        Balance(0, 0),
        (previousValue, element) => Balance(
            previousValue.confirmed + (element as Balance).confirmed,
            previousValue.unconfirmed + element.unconfirmed));
  }
}
