import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/models/account.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class AccountsService {
  Reservoir accounts;
  Reservoir addresses;
  Reservoir histories;

  AccountsService(this.accounts, this.addresses, this.histories);

  void init() {
    accounts.changes.listen((change) {
      change.when(added: (added) {
        Account account = added.data;
        addresses.save(account.deriveAddress(0, NodeExposure.Internal));
        addresses.save(account.deriveAddress(0, NodeExposure.External));
      }, updated: (updated) {
        /* Name or settings have changed */
        // UI updates
        // TODO
      }, removed: (removed) {
        // remove electrum subscriptions (unsubscribe)
        // how do we manage subscriptions if we don't remember them?
        // Should they be a Reservoir? Or indexed on the client? Or other?
        // TODO

        removeAddresses(removed.id as String);

        // UI updates
        // TODO
      });
    });
  }

  void removeAddresses(String accountId) {
    addresses.indices['account']!
        .getAll(accountId)!
        .forEach((address) => addresses.remove(address));
  }

  OrderedSet<Address> getAddressesByExposure(
      String accountId, NodeExposure exposure) {
    return addresses.indices['account-exposure']!.getAll('$accountId:$exposure')
        as OrderedSet<Address>;
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(String accountId, NodeExposure exposure) {
    var gap = 0;
    // TODO - fix this!
    // must include exposure...
    // must access all of history by indicies or something...
    var exposureAddresses = getAddressesByExposure(accountId, exposure);
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (histories.indices['scripthash']!
                  .getAll(exposureAddress.scripthash)
                  .isEmpty
              ? 1
              : 0);
    }
    // TODO fix get null thing
    if (gap < 10) {
      return accounts
          .get(accountId)
          .deriveAddress(exposureAddresses.length, exposure);
      //  return deriveBatch(hdIndex, exposure, 10 - gap);
    }
  }
}
