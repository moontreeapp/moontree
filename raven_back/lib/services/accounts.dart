import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/models/account.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

class nodeLocation {
  int index;
  NodeExposure exposure;

  nodeLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

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
    getAccountAddresses(accountId)!
        .forEach((address) => addresses.remove(address));
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(String accountId, NodeExposure exposure) {
    var gap = 0;
    var exposureAddresses = getAccountAddresses(accountId, exposure);
    exposureAddresses =
        (exposureAddresses == null) ? OrderedSet<Address>() : exposureAddresses;
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
    }
  }

  //// Account Scripthashes ////////////////////////////////////////////////////

  /// returns account addresses in order
  OrderedSet<Address>? getAccountAddresses(String accountId,
      [NodeExposure? exposure]) {
    return addresses
            .indices[(exposure == null) ? 'account' : 'account-exposure']!
            .getAll((exposure == null) ? accountId : '$accountId:$exposure')
        as OrderedSet<Address>;
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(String accountId,
      [NodeExposure exposure = NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var account = accounts.get(accountId)!;
    var i = 0;
    for (var address in getAccountAddresses(accountId, exposure)!) {
      if (histories.indices['scripthash']!.getAll(address.scripthash).isEmpty) {
        return account.deriveWallet(i, exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return account.deriveWallet(i, exposure);
  }

  nodeLocation? getNodeLocationOf(String scripthash, String accountId) {
    var i = 0;
    for (var address
        in getAccountAddresses(accountId, NodeExposure.Internal)!) {
      if (address.scripthash == scripthash) {
        return nodeLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in getAccountAddresses(accountId, NodeExposure.External)!) {
      if (address.scripthash == scripthash) {
        return nodeLocation(i, NodeExposure.External);
      }
      i = i + 1;
    }
  }
}
