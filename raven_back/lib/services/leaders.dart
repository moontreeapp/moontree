import 'dart:async';

import 'package:raven/utils/derivation_path.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';

class AddressDerivationService extends Service {
  AccountReservoir accounts;
  WalletReservoir wallets;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressDerivationService(
    this.accounts,
    this.wallets,
    this.addresses,
    this.histories,
  ) : super();

  @override
  void init() {
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        addresses.save(deriveAddress(wallet, 0, NodeExposure.Internal));
        addresses.save(deriveAddress(wallet, 0, NodeExposure.External));
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
      var leaderWallet = wallets.get(address.walletId)!;
      maybeSaveNewAddress(leaderWallet, NodeExposure.Internal);
      maybeSaveNewAddress(leaderWallet, NodeExposure.External);
    }
  }

  void maybeSaveNewAddress(LeaderWallet leaderWallet, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(
    LeaderWallet leaderWallet,
    NodeExposure exposure,
  ) {
    var gap = 0;
    var exposureAddresses =
        addresses.byWalletExposure.getAll('${leaderWallet.id}:$exposure');
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (histories.byScripthash.getAll(exposureAddress.scripthash).isEmpty
              ? 1
              : 0);
    }
    if (gap < 10) {
      return deriveAddress(leaderWallet, exposureAddresses.length, exposure);
    }
  }

  Address deriveAddress(
    LeaderWallet wallet,
    int hdIndex,
    NodeExposure exposure,
  ) {
    var net = accounts.get(wallet.accountId)!.net;
    var seededWallet = deriveWallet(wallet, net, hdIndex, exposure);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.id,
        accountId: wallet.accountId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: net);
  }

  HDWallet deriveWallet(
    LeaderWallet wallet,
    Net net,
    int hdIndex, [
    exposure = NodeExposure.External,
  ]) {
    var seededWallet = HDWallet.fromSeed(wallet.seed, network: networks[net]!);
    return seededWallet
        .derivePath(getDerivationPath(hdIndex, exposure: exposure));
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(
    String walletId, [
    NodeExposure exposure = NodeExposure.Internal,
  ]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var leaderWallet = leaders.get(walletId)!;
    var i = 0;
    for (var address
        in addresses.byWalletExposure.getAll('$walletId:$exposure')) {
      if (histories.byScripthash.getAll(address.scripthash).isEmpty) {
        var net = accounts.get(leaderWallet.accountId)!.net;
        return deriveWallet(leaderWallet, net, i, exposure);
        //return leaderWallet.deriveWallet(i, exposure); // service
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    var net = accounts.get(leaderWallet.accountId)!.net;
    return deriveWallet(leaderWallet, net, i, exposure);
  }
}
