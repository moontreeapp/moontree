import 'package:raven/reservoir_helper.dart';
import 'package:raven/subjects/reservoir.dart';

import 'models.dart';
import 'records/node_exposure.dart';

late Reservoir accounts;
late Reservoir addresses;

void setup() {
  accounts =
      Reservoir(HiveBoxSource('accounts'), (account) => account.accountId);

  addresses =
      Reservoir(HiveBoxSource('addresses'), (address) => address.scripthash)
        ..addIndex('account', (address) => address.accountId)
        ..addIndex('account-exposure',
            (address) => '${address.accountId}:${address.exposure}');

  var resHelper = ReservoirHelper(accounts, addresses);

  accounts.changes.listen((change) {
    change.when(added: (added) {
      Account account = added.data;
      addresses.save(account.deriveAddress(0, NodeExposure.Internal));
      addresses.save(account.deriveAddress(0, NodeExposure.External));
    }, updated: (updated) {
      // what's going to change on the account? only the name?
    }, removed: (removed) {
      // - unsubscribe from addresses (scripthash)
      // - delete in-memory addresses
      // - delete in-memory balances, histories, unspents
      // - UI updates
      // - remove from database if it exists
      //   - Truth.instance.removeScripthashesOf(event.value.accountId);
      //   - Truth.instance.accountUnspents.delete(event.value.accountId);
    });
  });

  // TODO: add AddressSubscriptionService here

  addresses.changes.listen((change) {
    change.when(added: (added) {
      // pass - see AddressSubscriptionService
    }, updated: (updated) {
      Address address = updated.data;
      resHelper.setBalance(
          address.accountId, resHelper.calculateBalance(address.accountId));
    }, removed: (removed) {
      // if this happens its because the account has been removed...
      // so do the removal steps that make sense here.
    });
  });
}
