import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/waiters/accounts/balance.dart';

class AccountBalanceService extends Service {
  HistoryReservoir histories;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceService(this.histories) : super();

  @override
  void init() {
    var waiter = BalanceWaiter();
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(waiter.calculateBalance);
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
