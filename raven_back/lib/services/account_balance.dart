import 'dart:async';

import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/waiters/accounts/balance.dart';

class AccountBalanceService extends Service {
  HistoryReservoir histories;
  BalanceWaiter balanceWaiter;

  late StreamSubscription<List<Change>> listener;

  AccountBalanceService(this.histories, this.balanceWaiter) : super();

  @override
  void init() {
    listener = histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen(balanceWaiter.calculateBalance);
  }

  @override
  void deinit() {
    listener.cancel();
  }
}
