import 'dart:async';

import 'package:raven/records.dart';
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
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        if (wallet is SingleWallet) {
          addresses.save(waiter.toAddress(wallet));
          addresses.save(waiter.toAddress(wallet));
        }
      }, updated: (updated) {
        /* moved account */
      }, removed: (removed) {
        /* handled by LeadersService*/
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
