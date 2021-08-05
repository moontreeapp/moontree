import 'dart:async';

import 'package:raven/models.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/service.dart';

class AddressesService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressesService(this.wallets, this.addresses, this.histories) : super();

  @override
  void init() {
    //AddressSubscriptionService(wallets, addresses, client);
    listener = addresses.changes.listen((change) {
      change.when(added: (added) {
        // pass - see AddressSubscriptionService
      }, updated: (updated) {
        Address address = updated.data;
        wallets.setBalance(
            address.walletId, calculateBalance(address.walletId));
      }, removed: (removed) {
        // always triggered by account removal
        histories.removeHistories(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }

  Balance calculateBalance(String walletId) {
    return addresses.indices['account']!.getAll(walletId).fold(
        Balance(confirmed: 0, unconfirmed: 0),
        (previousValue, element) => Balance(
            confirmed: previousValue.confirmed + (element as Balance).confirmed,
            unconfirmed: previousValue.unconfirmed + element.unconfirmed));
  }
}
