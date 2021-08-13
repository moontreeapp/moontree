import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/services/service.dart';

class AddressesService extends Service {
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressesService(
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
