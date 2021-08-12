import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallets/single.dart';
import 'package:raven/services/service.dart';

class AddressesService extends Service {
  AccountReservoir accounts;
  SingleWalletReservoir singles;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressesService(
    this.accounts,
    this.singles,
    this.addresses,
    this.histories,
  ) : super();

  @override
  void init() {
    listener = addresses.changes.listen((change) {
      change.when(
          added: (added) {},
          updated: (updated) {},
          removed: (removed) {
            // always triggered by account removal
            histories.removeHistories(removed.id as String);
          });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
