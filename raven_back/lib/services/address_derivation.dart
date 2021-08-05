import 'dart:async';

import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/models/leader_wallet.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/service.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

class AddressDerivationService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressDerivationService(this.wallets, this.addresses, this.histories)
      : super();

  @override
  void init() {
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        addresses.save(wallet.deriveAddress(0, NodeExposure.Internal));
        addresses.save(wallet.deriveAddress(0, NodeExposure.External));
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

  void maybeDeriveNewAddresses(List<Address> changedAddresses) async {
    for (var address in changedAddresses) {
      if (wallets.data[address.walletId] is LeaderWallet) {
        LeaderWallet leaderWallet = wallets.data[address.walletId];
        maybeSaveNewAddress(leaderWallet, NodeExposure.Internal);
        maybeSaveNewAddress(leaderWallet, NodeExposure.External);
      }
    }
  }

  void maybeSaveNewAddress(LeaderWallet leaderWallet, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet.id, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(String walletId, NodeExposure exposure) {
    var gap = 0;
    var exposureAddresses = addresses.byAccountAndExposure(walletId, exposure);
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
      return wallets
          .get(walletId)
          .deriveAddress(exposureAddresses.length, exposure);
    }
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(String walletId,
      [NodeExposure exposure = NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var account = wallets.get(walletId)!;
    var i = 0;
    for (var address in addresses.byAccountAndExposure(walletId, exposure)!) {
      if (histories.indices['scripthash']!.getAll(address.scripthash).isEmpty) {
        return account.deriveWallet(i, exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return account.deriveWallet(i, exposure);
  }
}
