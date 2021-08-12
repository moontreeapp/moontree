import 'dart:async';

import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallets/leader.dart';
import 'package:raven/services/service.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;

class AddressDerivationService extends Service {
  LeaderWalletReservoir leader;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressDerivationService(this.leader, this.addresses, this.histories)
      : super();

  @override
  void init() {
    listener = leader.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        if (wallet is SingleWallet) {
          addresses.save(wallet.deriveAddress());
        } else {
          addresses.save(wallet.deriveAddress(0, NodeExposure.Internal));
          addresses.save(wallet.deriveAddress(0, NodeExposure.External));
        }
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
      if (leader.primaryIndex.getOne(address.walletId) is LeaderWallet) {
        LeaderWallet leaderWallet =
            leader.primaryIndex.getOne(address.walletId);
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
    var exposureAddresses =
        addresses.byWalletExposure.getAll('$walletId:$exposure');
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (histories.byScripthash.getAll(exposureAddress.scripthash).isEmpty
              ? 1
              : 0);
    }
    // TODO fix get null thing
    if (gap < 10) {
      return leader
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
    var account = leader.get(walletId)!;
    var i = 0;
    for (var address
        in addresses.byWalletExposure.getAll('$walletId:$exposure')) {
      if (histories.byScripthash.getAll(address.scripthash).isEmpty) {
        return account.deriveWallet(i, exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return account.deriveWallet(i, exposure);
  }
}
