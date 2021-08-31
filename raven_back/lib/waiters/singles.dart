import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';
import 'package:raven/services/services.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';

class SinglesWaiter extends Waiter {
  WalletReservoir wallets;
  AddressReservoir addresses;
  SingleWalletService singleWalletService;

  SinglesWaiter(
    this.wallets,
    this.addresses,
    this.singleWalletService,
  ) : super();

  @override
  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
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
    }));
  }
}
