import 'dart:async';

import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';
import 'package:raven/waiters.dart';

class LeadersService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  late StreamSubscription<Change> listener;

  LeadersService(this.wallets, this.addresses) : super();

  @override
  void init() {
    var waiter = LeaderWalletDerivationWaiter();
    // todo: change this into just listening to leader wallets
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        addresses.save(waiter.deriveAddress(wallet, 0, NodeExposure.Internal));
        addresses.save(waiter.deriveAddress(wallet, 0, NodeExposure.External));
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
