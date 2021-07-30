import 'package:raven/models/address.dart';
import 'package:raven/models/account.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountsService {
  Reservoir accounts;
  Reservoir addresses;

  AccountsService(this.accounts, this.addresses);

  void init() {
    accounts.changes.listen((change) {
      change.when(added: (added) {
        Account account = added.data;
        addresses.add(account.deriveAddress(0, NodeExposure.Internal));
        addresses.add(account.deriveAddress(0, NodeExposure.External));
      }, updated: (updated) {
        /* Name or settings have changed */
        // UI updates
        // TODO
      }, removed: (removed) {
        // remove electrum subscriptions (unsubscribe)
        // how do we manage subscriptions if we don't remember them? Should they be a Reservoir?
        // TODO

        removeAddresses(removed.id as String);

        // UI updates
        // TODO
      });
    });
  }

  void removeAddresses(String accountId) {
    var addressIndices = addresses.indices['account']!
        .getAll(accountId)!
        .map((address) => (address as Address).scripthash);
    for (var scripthash in addressIndices) {
      addresses.removeIndex(scripthash);
    }
  }
}
