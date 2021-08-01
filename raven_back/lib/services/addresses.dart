import 'package:raven/models.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoirs.dart';

class AddressesService {
  Reservoir accounts;
  Reservoir addresses;

  AddressesService(this.accounts, this.addresses);

  void init() {
    //AddressSubscriptionService(accounts, addresses, client);
    addresses.changes.listen((change) {
      change.when(added: (added) {
        // pass - see AddressSubscriptionService
      }, updated: (updated) {
        Address address = updated.data;
        setBalance(address.accountId, calculateBalance(address.accountId));
      }, removed: (removed) {
        // always triggered by account removal
        removeHistories(removed.id as String);
        unsubscribe(removed.id as String);
      });
    });
  }

  Balance calculateBalance(String accountId) {
    return addresses.indices['account']!.getAll(accountId)!.fold(
        Balance(0, 0),
        (previousValue, element) => Balance(
            previousValue.confirmed + (element as Balance).confirmed,
            previousValue.unconfirmed + element.unconfirmed));
  }

  // set the balance for an account
  void setBalance(String accountId, Balance balance) {
    // setBalance(accountId, calculateBalance(accountId));
    accounts.data[accountId].balance = balance;
    accounts.save(accountId);
  }

  void removeHistories(String scripthash) {
    return histories.indices['scripthash']!
        .getAll(scripthash)
        .forEach((history) => histories.remove(history));
  }

  void unsubscribe(String scripthash) {
    // TODO - where are subscriptions tracked?
  }
}
