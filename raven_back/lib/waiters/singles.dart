import 'package:raven/security/security.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';
import 'package:raven/services/services.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';

class SinglesWaiter extends Waiter {
  final CipherRegistry cipherRegistry;
  final WalletReservoir wallets;
  final AddressReservoir addresses;
  final SingleWalletService singleWalletService;

  SinglesWaiter(
    this.cipherRegistry,
    this.wallets,
    this.addresses,
    this.singleWalletService,
  ) : super();

  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is SingleWallet) {
            addresses.save(singleWalletService.toAddress(
                wallet, cipherRegistry.ciphers[wallet.cipherUpdate]!));
            addresses.save(singleWalletService.toAddress(
                wallet, cipherRegistry.ciphers[wallet.cipherUpdate]!));
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
