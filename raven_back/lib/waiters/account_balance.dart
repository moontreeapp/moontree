import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/services.dart';

class AccountBalanceWaiter extends Waiter {
  HistoryReservoir histories;
  BalanceService balanceService;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceWaiter(this.histories, this.balanceService) : super();

  @override
  void init() {
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(balanceService.calculateBalance);
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
