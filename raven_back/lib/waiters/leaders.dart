import 'package:raven/security/security.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/services/services.dart';

class LeadersWaiter extends Waiter {
  final CipherRegistry cipherRegistry;
  final WalletReservoir wallets;
  final AddressReservoir addresses;
  final LeaderWalletDerivationService leaderWalletDerivationService;

  LeadersWaiter(
    this.cipherRegistry,
    this.wallets,
    this.addresses,
    this.leaderWalletDerivationService,
  ) : super();

  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is LeaderWallet) {
            leaderWalletDerivationService.deriveFirstAddressAndSave(
                wallet, cipherRegistry.ciphers[wallet.cipherUpdate]!);
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          addresses.removeAddresses(removed.data);
        });
      });
    }));
  }
}
