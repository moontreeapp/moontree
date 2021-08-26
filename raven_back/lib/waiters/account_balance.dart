import 'package:reservoir/reservoir.dart';

import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/utils/buffer_count_window.dart';
import 'package:raven/services.dart';

class AccountBalanceWaiter extends Waiter {
  HistoryReservoir histories;
  BalanceService balanceService;

  AccountBalanceWaiter(this.histories, this.balanceService) : super();

  @override
  void init() {
    listeners.add(histories.changes
        .bufferCountTimeout(25, Duration(milliseconds: 50))
        .listen((List<List<Change>> changes) {
      print('CHANGES');
      print(changes.expand((element) => element).toList());
      balanceService
          .calcuSaveBalance(changes.expand((element) => element).toList());
    }));
    print('ACCOUNT BALANCE WAITER INIT');
  }
}
