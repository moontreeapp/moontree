import 'dart:async';

import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/models/leader_wallet.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/services/service.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

class AddressDerivationService extends Service {
  Reservoir accounts;
  AddressReservoir addresses;
  Reservoir histories;
  late StreamSubscription<Change> listener;

  AddressDerivationService(this.accounts, this.addresses, this.histories)
      : super();

  @override
  void init() {
    listener = accounts.changes.listen((change) {
      change.when(added: (added) {
        Account account = added.data;
        addresses.save(account.deriveAddress(0, NodeExposure.Internal));
        addresses.save(account.deriveAddress(0, NodeExposure.External));
      }, updated: (updated) {
        /* Name or settings have changed */
      }, removed: (removed) {
        addresses.removeAddresses(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(String accountId, NodeExposure exposure) {
    var gap = 0;
    var exposureAddresses = addresses.byAccountAndExposure(accountId, exposure);
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

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(String accountId,
      [NodeExposure exposure = NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var account = accounts.get(accountId)!;
    var i = 0;
    for (var address in addresses.byAccountAndExposure(accountId, exposure)!) {
      if (histories.indices['scripthash']!.getAll(address.scripthash).isEmpty) {
        return account.deriveWallet(i, exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return account.deriveWallet(i, exposure);
  }
}
