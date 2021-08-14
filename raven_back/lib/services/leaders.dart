import 'dart:async';

import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';
import 'package:raven/waiters.dart';

class LeadersService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  LeaderWalletDerivationWaiter leaderWalletDerivationWaiter;
  late StreamSubscription<Change> listener;

  LeadersService(
    this.wallets,
    this.addresses,
    this.leaderWalletDerivationWaiter,
  ) : super();

  @override
  void init() {
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        if (wallet is LeaderWallet) {
          addresses.save(leaderWalletDerivationWaiter.deriveAddress(
              wallet, 0, NodeExposure.Internal));
          addresses.save(leaderWalletDerivationWaiter.deriveAddress(
              wallet, 0, NodeExposure.External));
        }
      }, updated: (updated) {
        /* moved account */
      }, removed: (removed) {
        addresses.removeAddresses(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
