import 'dart:async';

import 'package:raven/records.dart';
import 'package:raven/services.dart';
import 'package:raven/waiters.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/waiters/waiter.dart';

class SinglesWaiter extends Waiter {
  WalletReservoir wallets;
  AddressReservoir addresses;
  SingleWalletService singleWalletService;
  late StreamSubscription<Change> listener;

  SinglesWaiter(
    this.wallets,
    this.addresses,
    this.singleWalletService,
  ) : super();

  @override
  void init() {
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        if (wallet is SingleWallet) {
          addresses.save(singleWalletService.toAddress(wallet));
          addresses.save(singleWalletService.toAddress(wallet));
        }
      }, updated: (updated) {
        /* moved account */
      }, removed: (removed) {
        /* handled by LeadersWaiter*/
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
