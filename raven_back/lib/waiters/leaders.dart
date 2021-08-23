import 'dart:async';

import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/services.dart';

class LeadersWaiter extends Waiter {
  WalletReservoir wallets;
  AddressReservoir addresses;
  LeaderWalletDerivationService leaderWalletDerivationService;
  late StreamSubscription<List<Change>> listener;

  LeadersWaiter(
    this.wallets,
    this.addresses,
    this.leaderWalletDerivationService,
  ) : super();

  @override
  void init() {
    listeners.add(wallets.changes.listen((List<Change> changes) {
      changes.forEach((change) {
        change.when(added: (added) {
          var wallet = added.data;
          if (wallet is LeaderWallet) {
            leaderWalletDerivationService.deriveFirstAddressAndSave(wallet);
          }
        }, updated: (updated) {
          /* moved account */
        }, removed: (removed) {
          addresses.removeAddresses(removed.id as String);
        });
      });
    }));
  }
}
