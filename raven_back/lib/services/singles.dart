import 'dart:async';

import 'package:raven/records.dart';
import 'package:raven/waiters.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';

class SinglesService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  SingleWalletWaiter singleWalletWaiter;
  late StreamSubscription<Change> listener;

  SinglesService(
    this.wallets,
    this.addresses,
    this.singleWalletWaiter,
  ) : super();

  @override
  void init() {
    listener = wallets.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        if (wallet is SingleWallet) {
          addresses.save(singleWalletWaiter.toAddress(wallet));
          addresses.save(singleWalletWaiter.toAddress(wallet));
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
