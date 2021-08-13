import 'dart:async';

import 'package:raven/waiters.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';

class SinglesService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  late StreamSubscription<Change> listener;

  SinglesService(this.wallets, this.addresses) : super();

  @override
  void init() {
    var waiter = SingleWalletWaiter();
    // todo: change this into just listening to single wallets
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        addresses.save(waiter.toAddress(wallet));
        addresses.save(waiter.toAddress(wallet));
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
